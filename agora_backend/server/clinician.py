from aiohttp import web

from .util import validate_request, row_response, row_list_response


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


@routes.get("/clinician/requests")
async def get_requests(request):
    claims = validate_request(request)["agora"]

    validate_clinician(claims)

    async with request.app["pg_pool"].acquire() as connection:
        results = await connection.fetch("""
            SELECT user_id, user_name, user_full_name
            FROM serve_requests JOIN users ON patient_id = user_id
            WHERE clinician_id = $1""", claims["user_id"])

        return web.json_response([dict(result.items()) for result in results])


@routes.post("/clinician/request/response")
async def get_requests(request):
    claims = validate_request(request)["agora"]

    validate_clinician(claims)

    data = await request.json()

    try:
        patient_id, accept = data["patient_id"], data["accept"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Required values not passed!")

    async with request.app["pg_pool"].acquire() as connection:
        await connection.execute("""
            DELETE FROM serve_requests
            WHERE patient_id = $1 AND clinician_id = $2""",
            patient_id, claims["user_id"])

        if accept:
            await connection.execute("""
                INSERT INTO serves (patient_id, clinician_id) VALUES ($1, $2)""",
                patient_id, claims["user_id"])

            return web.Response(text="Request successfully accepted!")
        else:
            return web.Response(text="Request successfully denied!")
