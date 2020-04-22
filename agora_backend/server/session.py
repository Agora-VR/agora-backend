from datetime import datetime
from os.path import basename
from pathlib import Path
from tempfile import NamedTemporaryFile

from aiohttp import hdrs, web

from .util import validate_token, validate_user, validate_request, row_response, row_list_response


routes = web.RouteTableDef()

@routes.post("/session")
@validate_token
@validate_user("patient")
async def post_new_session(request):
    """
    Creates a new session.

    Requires a payload containing:

    + `datetime`: correctly formatted string (YYYY:MM:DD hh:mm:ss.mmmmmm) for when the session began
    + `type_name`: a string denoting the type of session

    On success, it returns a JSON-encoded string containing `session_id`,
    the session ID for the new session.
    """
    claims = request["claims"]

    data = await request.json()

    try:
        datetime_string, type_name = data["datetime"], data["type_name"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Not all required values in payload!")

    try:
        datetime_object = datetime.strptime(datetime_string, "%Y-%m-%d %H:%M:%S.%f")
    except ValueError:
        raise web.HTTPUnprocessableEntity(text="Invalid date format provided for datetime!")

    async with request.app["pg_pool"].acquire() as connection:
        session_id = await connection.fetchval("""
            INSERT INTO sessions (session_owner_id, session_datetime, type_name)
            VALUES ($1, $2, $3) RETURNING session_id""", claims["user_id"], datetime_object, type_name)

        return web.json_response({"session_id": session_id})


@routes.get("/session/{session_id}")
async def get_session_info(request):
    """
    Get information about a session by its ``session_id``.

    If the client is not authorized to view the session, then a
    422 response is returned.
    """
    claims = validate_request(request)["agora"]

    session_id = int(request.match_info["session_id"])

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT user_name, user_full_name, display_name, viewable.* FROM (
                SELECT * FROM sessions
                    JOIN session_types ON sessions.type_name = session_types.name
                WHERE session_owner_id = $1
                    OR $1 IN (SELECT clinician_id FROM serves
                            WHERE patient_id = (SELECT session_owner_id FROM sessions WHERE session_id = $2))
                    OR $1 IN (SELECT caregiver_id FROM oversees
                            WHERE patient_id = (SELECT session_owner_id FROM sessions WHERE session_id = $2))
                ORDER BY session_datetime DESC) AS viewable JOIN users ON user_id = session_owner_id
            WHERE session_id = $2""")

        result = await statement.fetchrow(claims["user_id"], session_id)

        if result:
            return row_response(result)
        else:
            raise web.HTTPUnprocessableEntity(text="Client cannot access this session!")


@routes.get("/session/{session_id}/responses")
async def get_session_responses(request):
    claims = validate_request(request)["agora"]

    session_id = int(request.match_info["session_id"])

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT response_id, user_name, user_full_name, response_form_name, response_datetime
            FROM responses JOIN users ON response_owner_id = user_id
            WHERE response_id IN (SELECT response_id FROM responds WHERE session_id = $1)""")

        results = await statement.fetch(session_id)

        return row_list_response(results)


@routes.get("/session/{session_id}/forms")
async def get_post_session_forms(request):
    claims = validate_request(request)["agora"]

    session_id = int(request.match_info["session_id"])

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT * FROM session_types
            WHERE session_types.name = (
                SELECT sessions.type_name FROM sessions
                WHERE sessions.session_id = $1)""")

        result = await statement.fetchrow(session_id)

        return row_response(result)


@routes.post("/session/{session_id}/respond")
async def post_session_response(request):
    claims = validate_request(request)["agora"]

    data = await request.json()

    try:
        form_name, form_data = data["form_name"], data["form_data"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Not all required values in payload!")

    session_id = int(request.match_info["session_id"])

    async with request.app["pg_pool"].acquire() as connection:
        response_id = await connection.fetchval("""
            INSERT INTO responses (response_owner_id, response_form_name, response_datetime, response_data)
            VALUES ($1, $2, $3, $4) RETURNING response_id""",
            claims["user_id"], form_name, datetime.utcnow(), form_data)

        await connection.execute(
            """INSERT INTO responds (session_id, response_id) VALUES ($1, $2)""",
            session_id, int(response_id))

        return web.Response(text="Response to session recorded!")


@routes.get("/session/{session_id}/files")
@validate_token
async def get_session_files(request):
    """
    Get list of file types associated with the session.
    """
    claims = request["claims"]

    session_id = int(request.match_info["session_id"])

    async with request.app["pg_pool"].acquire() as connection:
        results = await connection.fetch("""
            SELECT session_files.type FROM session_files
            WHERE session_id = $1""",
            session_id)

        return row_list_response(results)


@routes.post("/session/{session_id}/files")
@validate_token
@validate_user("patient")
async def post_session_file(request):
    """
    Post a file associated with a session.

    Requires a multipart request. The first part must be
    JSON-encoded metadata containing the ``data_type`` of
    the file. The second part must contain the file itself,
    be it text or binary. Both parts must have the appropiate
    Content-Type headers.
    """
    claims = request["claims"]

    session_id = int(request.match_info["session_id"])

    reader = await request.multipart()

    metadata_part = await reader.next()

    try:
        content_type = metadata_part.headers[hdrs.CONTENT_TYPE]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="No metadata content type provided!")

    if content_type != "application/json":
        raise web.HTTPUnprocessableEntity(text="Content type of part must be 'application/json'!")

    metadata = await metadata_part.json()

    try:
        data_type = metadata["data_type"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Not all require parameters passed in metadata!")

    file_part = await reader.next()

    size = 0

    with NamedTemporaryFile(dir=request.app["storage_path"], delete=False) as tmp_file:
        while chunk := await file_part.read_chunk():
            size += len(chunk)

            tmp_file.write(chunk)

    tmp_name = basename(tmp_file.name)

    async with request.app["pg_pool"].acquire() as connection:
        await connection.execute("""
            INSERT INTO session_files (session_id, type, name)
            VALUES ($1, $2, $3)""", session_id, data_type, tmp_name)

    return web.Response(text=f"Successfully stored file of size {size} bytes")


TYPE_MIMES = {
    "audio_session": "audio/mpeg",
    "distraction_timestamp": "text/csv",
    "heart_rate_session": "text/csv",
    "text_script": "text/plain",
    "volume_session": "text/csv",
}


@routes.get("/session/{session_id}/files/script")
@validate_token
async def get_session_script(request):
    """
    Get script for session type
    """
    claims = request["claims"]

    session_id = int(request.match_info["session_id"])

    async with request.app["pg_pool"].acquire() as connection:
        type_script = await connection.fetchval("""
            SELECT speech FROM sessions JOIN session_types ON sessions.type_name = session_types.name WHERE session_id = $1""",
            session_id)

        return web.Response(text=type_script)


@routes.get("/session/{session_id}/files/{file_type}")
@validate_token
async def get_session_file(request):
    """
    Get a file associated with a session.
    """
    claims = request["claims"]

    session_id = int(request.match_info["session_id"])
    file_type = request.match_info["file_type"]

    async with request.app["pg_pool"].acquire() as connection:
        file_name = await connection.fetchval("""
            SELECT name FROM session_files WHERE session_id = $1 and type = $2""",
            session_id, file_type)

        if not file_name:
            raise web.HTTPUnprocessableEntity(text="Session does not have that file type!")

        file_path = request.app["storage_path"].joinpath(file_name)

        if not file_path.is_file():
            raise web.HTTPUnprocessableEntity(text="Request file is missing!!!")

        response = web.FileResponse(file_path)

        # NOTE: This is hard coded right now, will come from a table in the future
        # NOTE: I am not actually fixing this, sry
        try:
            response.content_type = TYPE_MIMES[file_type]
        except KeyError:
            response.content_type = "text/plain"

        return response
