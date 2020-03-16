from datetime import datetime
from os.path import basename
from tempfile import NamedTemporaryFile

from aiohttp import hdrs, web

from .util import validate_token, validate_user, validate_request, row_response, row_list_response


routes = web.RouteTableDef()


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
            SELECT user_name, user_full_name, viewable.* FROM (
                SELECT * FROM sessions
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


@routes.get("/session/{session_id}/files/{file_type}")
async def get_session_file(request):
    pass
