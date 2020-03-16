from asyncio import get_event_loop

from asyncpg import create_pool
from pytest import fixture, mark, yield_fixture

from agora_backend.server import get_app
from testing_util import get_auth_token, testing_app

NAME, PASSWORD = "clin123", "password123"


async def test_patient_success(aiohttp_client, testing_app):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    response = await client.get("/clinician/patients",
        headers={"Authorization": f"Bearer {auth_token}"})

    # Test status code
    assert response.status == 200
