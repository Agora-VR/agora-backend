from aiohttp import web

from .util import validate_request, row_response, row_list_response


def validate_caregiver(session):
    if session["user_type"] != "caregiver":
        raise web.HTTPUnprocessableEntity(text="Client is not a valid user type for this endpoint!")


routes = web.RouteTableDef()


@routes.get("/caregiver/patients")
async def get_patients(request):
    session = validate_request(request)["agora"]

    validate_caregiver(session)

    user_id, user_type = session["user_id"], session["user_type"]

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT user_id, user_name, user_full_name
            FROM oversees JOIN users ON users.user_id = oversees.patient_id
            WHERE oversees.caregiver_id = $1""")

        results = await clinician_stmt.fetch(user_id)

        return web.json_response([dict(result.items()) for result in results])


@routes.get("/caregiver/requests")
async def get_requests(request):
    claims = validate_request(request)["agora"]

    validate_caregiver(claims)

    async with request.app["pg_pool"].acquire() as connection:
        results = await connection.fetch("""
            SELECT user_id, user_name, user_full_name
            FROM oversee_requests JOIN users ON patient_id = user_id
            WHERE caregiver_id = $1""", claims["user_id"])

        return web.json_response([dict(result.items()) for result in results])


@routes.post("/caregiver/request/response")
async def get_requests(request):
    claims = validate_request(request)["agora"]

    validate_caregiver(claims)

    data = await request.json()

    try:
        patient_id, accept = data["patient_id"], data["accept"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Required values not passed!")

    async with request.app["pg_pool"].acquire() as connection:
        await connection.execute("""
            DELETE FROM oversee_requests
            WHERE patient_id = $1 AND caregiver_id = $2""",
            patient_id, claims["user_id"])

        if accept:
            await connection.execute("""
                INSERT INTO oversees (patient_id, caregiver_id) VALUES ($1, $2)""",
                patient_id, claims["user_id"])

            return web.Response(text="Request successfully accepted!")
        else:
            return web.Response(text="Request successfully denied!")
