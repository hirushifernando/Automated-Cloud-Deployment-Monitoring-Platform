
import pytest
from fastapi.testclient import TestClient

from app import database
from app.main import app


# Create a separate temporary database for testing
@pytest.fixture
def client(tmp_path, monkeypatch):
    test_db = tmp_path / "test_tasks.db"

    monkeypatch.setattr(
        database,
        "DATABASE_PATH",
        str(test_db)
    )

    with TestClient(app) as test_client:
        yield test_client


# Test home endpoint
def test_home(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["status"] == "running"


# Test health endpoint
def test_health(client):
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


# Test task creation
def test_create_task(client):
    response = client.post(
        "/tasks",
        json={
            "title": "Learn Python",
            "description": "Python practice",
            "completed": False
        }
    )

    assert response.status_code == 201
    assert response.json()["title"] == "Learn Python"


# Test retrieving all tasks
def test_get_tasks(client):
    client.post(
        "/tasks",
        json={"title": "Learn Docker"}
    )

    response = client.get("/tasks")

    assert response.status_code == 200
    assert len(response.json()) == 1


# Test updating a task
def test_update_task(client):
    created = client.post(
        "/tasks",
        json={"title": "Old task"}
    )

    task_id = created.json()["id"]

    response = client.put(
        f"/tasks/{task_id}",
        json={
            "title": "Updated task",
            "description": "Updated description",
            "completed": True
        }
    )

    assert response.status_code == 200
    assert response.json()["title"] == "Updated task"
    assert response.json()["completed"] == 1


# Test deleting a task
def test_delete_task(client):
    created = client.post(
        "/tasks",
        json={"title": "Delete me"}
    )

    task_id = created.json()["id"]

    response = client.delete(
        f"/tasks/{task_id}"
    )

    assert response.status_code == 200

    get_response = client.get(
        f"/tasks/{task_id}"
    )

    assert get_response.status_code == 404


# Test retrieving a task that does not exist
def test_task_not_found(client):
    response = client.get("/tasks/999")

    assert response.status_code == 404


def test_get_task(client):
    create_response = client.post(
        "/tasks",
        json={
            "title": "Test task",
            "description": "Testing get task",
            "completed": False
        }
    )

    task_id = create_response.json()["id"]

    response = client.get(f"/tasks/{task_id}")

    assert response.status_code == 200
    assert response.json()["title"] == "Test task"


def test_update_task_not_found(client):
    response = client.put(
        "/tasks/999",
        json={
            "title": "Updated task",
            "description": "Testing missing task",
            "completed": True
        }
    )

    assert response.status_code == 404
    assert response.json()["detail"] == "Task not found"


def test_delete_task_not_found(client):
    response = client.delete("/tasks/999")

    assert response.status_code == 404
    assert response.json()["detail"] == "Task not found"

