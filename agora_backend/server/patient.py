from aiohttp import web

from .util import validate_request, row_response, row_list_response


def validate_patient(claims):
    if claims["user_type"] != "patient":
        raise web.HTTPUnprocessableEntity(text="Client is not a valid user type for this endpoint!")


routes = web.RouteTableDef()


@routes.post("/patient/caregiver")
async def post_caregiver_request(request):
    claims = validate_request(request)["agora"]

    validate_patient(claims)

    data = await request.json()

    try:
        caregiver_user_name = data["user_name"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Required values not passed!")

    async with request.app["pg_pool"].acquire() as connection:
        caregiver_user_id = await connection.fetchval("""
            SELECT user_id FROM users NATURAL JOIN user_types
            WHERE user_name = $1 AND user_type_name = 'caregiver'""",
            caregiver_user_name)

        if caregiver_user_id:
            await connection.execute("""
                INSERT INTO oversee_requests (patient_id, caregiver_id) VALUES ($1, $2)""",
                claims["user_id"], caregiver_user_id)

            return web.Response(text="Caregiver request sent!")
        else:
            raise web.HTTPUnprocessableEntity(text="No caregiver with that username!")


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


@routes.post("/patient/clinician")
async def post_clinician_request(request):
    claims = validate_request(request)["agora"]

    validate_patient(claims)

    data = await request.json()

    try:
        clinician_user_name = data["user_name"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Required values not passed!")

    async with request.app["pg_pool"].acquire() as connection:
        clinician_user_id = await connection.fetchval("""
            SELECT user_id FROM users NATURAL JOIN user_types
            WHERE user_name = $1 AND user_type_name = 'clinician'""",
            clinician_user_name)

        if clinician_user_id:
            await connection.execute("""
                INSERT INTO serve_requests (clinician_id, patient_id) VALUES ($1, $2)""",
                clinician_user_id, claims["user_id"])

            return web.Response(text="Clinician request sent!")
        else:
            raise web.HTTPUnprocessableEntity(text="No clinician with that username!")


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
