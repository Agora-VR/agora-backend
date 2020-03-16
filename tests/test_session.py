from json import dumps

from aiohttp import FormData
import pytest

from testing_util import get_auth_token, testing_app


NAME, PASSWORD = "pat123", "password123"

SESSION_ID = 1

AUDIO_FILE = "wheres_my_juul.ogg"
DATA_TYPE = "audio_session"


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


async def test_post_session_file(aiohttp_client, testing_app, datadir):
    client = await aiohttp_client(testing_app)

    auth_token = await get_auth_token(client, NAME, PASSWORD)

    async def get_tmp_count():
        """ Get the number of temporary files in the test's tempdir """
        # NOTE: There is already a file inside of the temporary directory
        return len(client.server.app["storage_path"].listdir())

    # Count of files in temporary directory
    tmp_file_count = await get_tmp_count()

    # Count of rows in session files
    db_file_count = await get_db_session_file_count(client, auth_token)

    form_data = FormData()

    form_data.add_field(
        "metadata",
        dumps({"data_type": DATA_TYPE}),
        content_type="application/json"
    )

    form_data.add_field(
        "file",
        open(datadir / AUDIO_FILE, "rb"),
        content_type="audio/ogg"
    )

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
