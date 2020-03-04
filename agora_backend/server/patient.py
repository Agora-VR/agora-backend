from aiohttp import web

from .util import validate_request, row_response, row_list_response


def validate_patient(session):
    if session["user_type"] != "patient":
        raise web.HTTPUnprocessableEntity(text="Client is not a valid user type for this endpoint!")


routes = web.RouteTableDef()


@routes.get("/patient/clinicians")
async def get_clinicians(request):
    session = validate_request(request)["agora"]

    validate_patient(session)

    async with request.app["pg_pool"].acquire() as connection:
        clinician_stmt = await connection.prepare("""
            SELECT user_id, user_name, user_full_name
            FROM serves JOIN users ON users.user_id = serves.clinician_id
            WHERE serves.patient_id = $1""")

        results = await clinician_stmt.fetch(session["user_id"])

        # return web.json_response([dict(result.items()) for result in results])
        return row_list_response(results)
