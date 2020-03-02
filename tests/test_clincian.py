from asyncio import get_event_loop

from asyncpg import create_pool
from pytest import fixture, mark, yield_fixture

from agora_backend.server import get_app

NAME, PASSWORD = "clin123", "password123"


async def test_patient_success(aiohttp_client):
    client = await aiohttp_client(get_app)

    auth_response = await client.post("/authenticate",
        json={"user_name": NAME, "user_pass": PASSWORD})

    auth_token = await auth_response.text()

    response = await client.get("/clinician/patients",
        headers={"Authorization": f"Bearer {auth_token}"})

    assert response.status == 200


async def test_session_id_success(aiohttp_client):
    client = await aiohttp_client(get_app)

    auth_response = await client.post("/authenticate",
        json={"user_name": NAME, "user_pass": PASSWORD})

    auth_token = await auth_response.text()

    response = await client.get("/clinician/session/1",
        headers={"Authorization": f"Bearer {auth_token}"})

    assert response.status == 200
