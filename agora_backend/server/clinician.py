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
