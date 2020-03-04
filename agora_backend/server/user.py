from aiohttp import web

from .util import validate_request, row_response, row_list_response


routes = web.RouteTableDef()


@routes.get("/user/{patient_id}")
async def get_patient_sessions(request):
    session = validate_request(request)["agora"]

    try:
        patient_id = int(request.match_info["patient_id"])
    except ValueError:
        raise web.HTTPUnprocessableEntity(text="Invalid patient_id passed!")

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT user_name, user_full_name FROM users WHERE user_id = $1
            """)

        result = await statement.fetchrow(patient_id)

        return row_response(result)


@routes.get("/user/{patient_id}/sessions")
async def get_patient_sessions(request):
    session = validate_request(request)["agora"]

    try:
        patient_id = int(request.match_info["patient_id"])
    except ValueError:
        raise web.HTTPUnprocessableEntity(text="Invalid patient_id passed!")

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT * FROM sessions
            WHERE session_owner_id = $2
                AND (
                    $1 = $2
                    OR $1 IN (SELECT clinician_id FROM serves WHERE patient_id = $2)
                    OR $1 IN (SELECT caregiver_id FROM oversees WHERE patient_id = $2)
                )
            ORDER BY session_datetime DESC
            """)

        results = await clinician_stmt.fetch(session["user_id"], patient_id)

        return row_list_response(results)
