from aiohttp import web

from .util import validate_request, row_response, row_list_response

"""
SELECT user_id, user_name, user_full_name, form_name, form_data, response_data
FROM responds NATURAL JOIN responses
	JOIN users ON response_owner_id = user_id
	JOIN forms ON response_form_name = form_name
WHERE session_id = 1;
"""

""" clinician get all patient sessions
SELECT *
FROM sessions
WHERE session_owner_id IN (SELECT patient_id FROM serves WHERE clinician_id = 15)
"""

""" clinician get all sessions by user
SELECT *
FROM sessions
WHERE session_owner_id IN (SELECT patient_id FROM serves WHERE clinician_id = 15)
	AND session_owner_id = 14
"""

def validate_clinician(session):
    if session["user_type"] != "clinician":
        raise web.HTTPUnprocessableEntity(text="Client is not a valid user type for this endpoint!")


routes = web.RouteTableDef()


@routes.get("/clinician/patients")
async def get_patients(request):
    session = validate_request(request)["agora"]

    validate_clinician(session)

    user_id, user_type = session["user_id"], session["user_type"]

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT user_id, user_name, user_full_name
            FROM serves JOIN users ON users.user_id = serves.patient_id
            WHERE serves.clinician_id = $1""")

        results = await clinician_stmt.fetch(user_id)

        return web.json_response([dict(result.items()) for result in results])


# @routes.get("/clinician/patient/{patient_name}")
# async def get_patient_info(request):
#     pass


@routes.get("/clinician/session/{session_id}")
async def get_patient_session(request):
    claims = validate_request(request)["agora"]

    validate_clinician(claims)

    try:
        session_id = int(request.match_info["session_id"])
    except KeyError:
        raise web.HTTPUnprocessableEntity(text=f"No session_id passed!")

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT * FROM sessions
            WHERE session_owner_id IN (SELECT patient_id FROM serves WHERE clinician_id = $1)
                AND session_id = $2""")

        result = await clinician_stmt.fetchrow(claims["user_id"], session_id)

        if result:
            return row_response(result)
        else:
            raise web.HTTPUnprocessableEntity(text=f"User forbidden access to session index '{session_id}'")
