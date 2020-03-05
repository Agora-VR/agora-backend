from aiohttp import web

from .util import validate_request, row_response, row_list_response


def validate_patient(claims):
    if claims["user_type"] != "patient":
        raise web.HTTPUnprocessableEntity(text="Client is not a valid user type for this endpoint!")


routes = web.RouteTableDef()


@routes.get("/patient/clinicians")
async def get_clinicians(request):
    claims = validate_request(request)["agora"]

    validate_patient(claims)

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT user_id, user_name, user_full_name
            FROM serves JOIN users ON users.user_id = serves.clinician_id
            WHERE serves.patient_id = $1""")

        results = await clinician_stmt.fetch(claims["user_id"])

        return row_list_response(results)


@routes.get("/patient/caregivers")
async def get_caregivers(request):
    claims = validate_request(request)["agora"]

    validate_patient(claims)

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT user_id, user_name, user_full_name
            FROM oversees JOIN users ON users.user_id = oversees.caregiver_id
            WHERE oversees.patient_id = $1""")

        results = await clinician_stmt.fetch(claims["user_id"])

        return row_list_response(results)
