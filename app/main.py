
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from prometheus_fastapi_instrumentator import Instrumentator

from app.database import get_connection, init_db


# Initialize database when application starts
@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield


# Create FastAPI application
app = FastAPI(
    title="CloudOps Task Management API",
    description="A cloud-ready API with automated DevOps deployment.",
    version="1.0.0",
    lifespan=lifespan
)


# Task creation model
class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: str = ""
    completed: bool = False


# Task update model
class TaskUpdate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: str = ""
    completed: bool = False


# Welcome endpoint
@app.get("/")
def home():
    return {
        "message": "Welcome to CloudOps Task Management API",
        "status": "running"
    }


# Health check endpoint
@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }


# Get all tasks
@app.get("/tasks")
def get_tasks():
    connection = get_connection()

    tasks = connection.execute(
        "SELECT * FROM tasks"
    ).fetchall()

    connection.close()

    return [dict(task) for task in tasks]


# Get one task by ID
@app.get("/tasks/{task_id}")
def get_task(task_id: int):
    connection = get_connection()

    task = connection.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    connection.close()

    if task is None:
        raise HTTPException(
            status_code=404,
            detail="Task not found"
        )

    return dict(task)


# Create a new task
@app.post("/tasks", status_code=201)
def create_task(task: TaskCreate):
    connection = get_connection()

    cursor = connection.execute(
        """
        INSERT INTO tasks (title, description, completed)
        VALUES (?, ?, ?)
        """,
        (task.title, task.description, task.completed)
    )

    connection.commit()

    task_id = cursor.lastrowid

    new_task = connection.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    connection.close()

    return dict(new_task)


# Update an existing task
@app.put("/tasks/{task_id}")
def update_task(task_id: int, task: TaskUpdate):
    connection = get_connection()

    existing_task = connection.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    if existing_task is None:
        connection.close()

        raise HTTPException(
            status_code=404,
            detail="Task not found"
        )

    connection.execute(
        """
        UPDATE tasks
        SET title = ?, description = ?, completed = ?
        WHERE id = ?
        """,
        (task.title, task.description, task.completed, task_id)
    )

    connection.commit()

    updated_task = connection.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    connection.close()

    return dict(updated_task)


# Delete a task
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    connection = get_connection()

    existing_task = connection.execute(
        "SELECT * FROM tasks WHERE id = ?",
        (task_id,)
    ).fetchone()

    if existing_task is None:
        connection.close()

        raise HTTPException(
            status_code=404,
            detail="Task not found"
        )

    connection.execute(
        "DELETE FROM tasks WHERE id = ?",
        (task_id,)
    )

    connection.commit()
    connection.close()

    return {
        "message": "Task deleted successfully"
    }


# Enable Prometheus metrics
Instrumentator().instrument(app).expose(app)
