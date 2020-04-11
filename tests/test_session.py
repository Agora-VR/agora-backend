from datetime import datetime
from json import dumps

from aiohttp import FormData
import pytest

from testing_util import get_auth_token, testing_app


NAME, PASSWORD = "pat123", "password123"

SESSION_ID = 1

AUDIO_FILE = "henry5.mp3"
DATA_TYPE = "audio_session"
CONTENT_TYPE = "audio/mpeg"


@pytest.mark.parametrize("endpoint", [
    f"/session/{SESSION_ID}/files",
])
async def test_session_get_request_status(aiohttp_client, testing_app, endpoint):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    response = await client.get(endpoint,
        headers={"Authorization": f"Bearer {auth_token}"})

    # Check that the number of files is
    assert response.status == 200


async def get_db_session_file_count(client, auth_token):
    """ Get number of session files recorded in the database """
    response = await client.get(f"/session/{SESSION_ID}/files",
        headers={"Authorization": f"Bearer {auth_token}"})

    return len(await response.json())


def get_multipart_file_data(directory):
    form_data = FormData()

    form_data.add_field(
        "metadata",
        dumps({"data_type": DATA_TYPE}),
        content_type="application/json"
    )

    form_data.add_field(
        "file",
        open(directory / AUDIO_FILE, "rb"),
        content_type=CONTENT_TYPE
    )

    return form_data


async def test_post_session_file(aiohttp_client, testing_app, datadir):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    async def get_tmp_count():
        """ Get the number of temporary files in the test's tempdir """
        # NOTE: There is already a file inside of the temporary directory
        return len(list(client.server.app["storage_path"].iterdir()))

    # Count of files in temporary directory
    tmp_file_count = await get_tmp_count()

    # Count of rows in session files
    db_file_count = await get_db_session_file_count(client, auth_token)

    form_data = get_multipart_file_data(datadir)

    response = await client.post(f"/session/{SESSION_ID}/files",
        data=form_data,
        headers={"Authorization": f"Bearer {auth_token}"})

    # Test status code
    assert response.status == 200

    # Test file was created
    assert await get_tmp_count() == tmp_file_count + 1

    # Test file was logged in database
    assert await get_db_session_file_count(client, auth_token) == db_file_count + 1

    # Clean up time!
    async with client.server.app["pg_pool"].acquire() as connection:
        await connection.execute(
            """DELETE FROM session_files WHERE session_id = $1 AND type = $2""",
            SESSION_ID, DATA_TYPE)


async def test_get_session_file_not_found(aiohttp_client, testing_app):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    response = await client.get(f"/session/{SESSION_ID}/files/audio_session",
        headers={"Authorization": f"Bearer {auth_token}"})

    # Check that the number of files is
    assert response.status == 422


async def test_get_session_file(aiohttp_client, testing_app, datadir):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    form_data = get_multipart_file_data(datadir)

    post_response = await client.post(f"/session/{SESSION_ID}/files",
        data=form_data,
        headers={"Authorization": f"Bearer {auth_token}"})

    assert post_response.status == 200

    get_response = await client.get(f"/session/{SESSION_ID}/files/{DATA_TYPE}",
        headers={"Authorization": f"Bearer {auth_token}"})

    assert get_response.status == 200

    # Clean up time!
    async with client.server.app["pg_pool"].acquire() as connection:
        await connection.execute(
            """DELETE FROM session_files WHERE session_id = $1 AND type = $2""",
            SESSION_ID, DATA_TYPE)


async def test_post_new_session(aiohttp_client, testing_app):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    datetime_now = datetime.now()

    post_response = await client.post("/session",
        json={"datetime": str(datetime_now), "type_name": "room"},
        headers={"Authorization": f"Bearer {auth_token}"})

    assert post_response.status == 200

    response_payload = await post_response.json()

    # print(response_payload)

    session_id = response_payload["session_id"]

    # Clean up time!
    async with client.server.app["pg_pool"].acquire() as connection:
        await connection.execute(
            """DELETE FROM sessions WHERE session_id = $1""", session_id)
