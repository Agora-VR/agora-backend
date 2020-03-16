from datetime import datetime
from hashlib import pbkdf2_hmac
from os import mkdir, urandom
from os.path import isdir

from aiohttp import web
import aiohttp_cors
from asyncpg import create_pool
from authlib.jose import errors, jwt
from datetime import datetime, timedelta
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.serialization import load_pem_private_key

from .caregiver import routes as caregiver_routes
from .clinician import routes as clinician_routes
from .patient import routes as patient_routes
from .session import routes as session_routes
from .user import routes as user_routes
from .util import validate_request, row_response, row_list_response


def load_keys(password):
    with open('private.pem', 'rb') as f:
        private_key = load_pem_private_key(
            f.read(), password=password.encode(), backend=default_backend())

    with open('public.pem', 'rb') as f:
        public_key = f.read()

    return public_key, private_key


routes = web.RouteTableDef()


@routes.post("/register")
async def post_user(request):
    """
    Register a new user.

    Requires a ``user_name``, ``user_pass`` and ``user_type``
    in the payload to create the new user.
    """
    data = await request.json()  # Use this like a dictionary

    # Try to get the user_name value from the post data
    try:
        user_name, user_pass, user_type = data["user_name"], data["user_pass"], data["user_type"]
        user_full_name = data["user_full_name"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Not all require parameters passed!")

    try:
        user_type_id = request.app["types"][user_type]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text=f"Invalid user type '{user_type}' provided!")

    password_salt = urandom(32)

    password_hash = pbkdf2_hmac("sha256", user_pass.encode(), password_salt, 100000)

    async with request.app["pg_pool"].acquire() as connection:
        # Validate if the user already exists
        validate_stmt = await connection.prepare("SELECT user_id FROM users WHERE user_name = $1")

        # If the user is already registered
        if await validate_stmt.fetchval(user_name):
            raise web.HTTPUnprocessableEntity(text=f"User '{user_name}' already registered!")

        await connection.execute("""
            INSERT INTO users (user_type_id, user_name, user_full_name, user_hash, user_salt)
            VALUES ($1, $2, $3, $4, $5)""",
            user_type_id, user_name, user_full_name, password_hash, password_salt)

        return web.Response(text=f"User '{user_name}' successfully registered!")


@routes.post("/authenticate")
async def authenticate_user(request):
    """
    Request an authentication token from the server. Requires
    ``user_name`` and ``user_pass`` values in the payload.

    Assuming the credentials are valid, the server will respond with
    a string containing the token. Otherwise, it will return a 422
    response.
    """
    data = await request.json()

    try:
        user_name, user_pass = data["user_name"], data["user_pass"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Not all keys provided!")

    async with request.app["pg_pool"].acquire() as connection:
        user_stmt = await connection.prepare("SELECT * FROM users NATURAL JOIN user_types WHERE user_name = $1")

        user_result = await user_stmt.fetchrow(user_name)

        if user_result is None:
            raise web.HTTPUnprocessableEntity(text="Invalid credential provided!")

        user_data = dict(user_result.items())

    user_hash, user_salt = user_data["user_hash"], user_data["user_salt"]

    password_hash = pbkdf2_hmac("sha256", user_pass.encode(), user_salt, 100000)

    # If the hashes don't match
    if password_hash != user_hash:
        raise web.HTTPUnprocessableEntity(text="Invalid credential provided!")

    private_key = request.app["private_key"]

    current_datetime = datetime.utcnow()
    expiration_delta = timedelta(minutes=20)

    user_id = user_data["user_id"]

    payload = {
        'iss': "Agora VR",
        'exp': current_datetime + expiration_delta,
        'agora': {
            'user_id': user_id,
            'user_name': user_data["user_name"],
            'user_type': user_data["user_type_name"],
        },
    }

    token = jwt.encode({'alg': "RS256"}, payload, private_key)

    request.app["tokens"][user_id] = token.decode()

    return web.Response(body=token)


@routes.get("/user/register_form")
async def get_register_form(request):
    """
    Get the appropiate registration form for the type of user.
    """
    session = validate_request(request)["agora"]

    user_type = session["user_type"]

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT forms.*
            FROM user_types JOIN forms ON user_type_form_name = form_name
            WHERE user_type_name = $1""")

        result = await statement.fetchrow(user_type)

        if result:
            return web.json_response(dict(result.items()))


@routes.post("/user/register_form")
async def post_register_form(request):
    """
    Post response to a registration form.

    Requires ``form_name`` (the name of the form being filled out)
    and ``form_data`` (the JSON string representation of the results)
    """

    claims = validate_request(request)["agora"]

    data = await request.json()

    try:
        form_name, form_data = data["form_name"], data["form_data"]
    except KeyError:
        raise web.HTTPUnprocessableEntity(text="Not all keys provided!")

    async with request.app["pg_pool"].acquire() as connection:
        response_id = await connection.fetchval("""
            INSERT INTO responses (response_owner_id, response_form_name, response_datetime, response_data)
            VALUES ($1, $2, $3, $4) RETURNING response_id""",
            claims["user_id"], form_name, datetime.utcnow(), form_data)

        await connection.execute("""UPDATE users SET user_response_id = $1 WHERE user_id = $2""",
            response_id, claims["user_id"])

        return web.Response(text="Form response registered successfully!")


@routes.get("/user/registration_response")
async def get_register_form(request):
    """
    Get the ``response_id`` for a user's submitted registration form
    """
    claims = validate_request(request)["agora"]

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT user_response_id FROM users WHERE user_id = $1""")

        result = await statement.fetchrow(claims["user_id"])

        if result:
            return web.json_response(dict(result.items()))


@routes.get("/form/{form_name}")
async def get_form_by_id(request):
    """
    View a form by it's ``form_name``
    """
    claims = validate_request(request)["agora"]

    form_name = request.match_info["form_name"]

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""SELECT * FROM forms WHERE form_name = $1""")

        result = await statement.fetchrow(form_name)

        if result:
            return row_response(result)


@routes.get("/form/response/{response_id}")
async def get_form_response(request):
    """
    View a response to a form by it's ``response_id``
    """
    claims = validate_request(request)["agora"]

    response_id = int(request.match_info["response_id"])

    async with request.app["pg_pool"].acquire() as connection:
        statement = await connection.prepare("""
            SELECT response_id, response_datetime, user_id, user_name, user_full_name, form_name, form_data, response_data
            FROM responses JOIN forms ON response_form_name = form_name JOIN users on response_owner_id = user_id
            WHERE response_id = $1""")

        results = await statement.fetchrow(response_id)

        return row_response(results)


@routes.get("/")
async def get_root(request):
    return web.Response(text=request.app["documentation"], content_type="text/html")


async def setup_app(app):
    # On server startup
    app["pg_pool"] = await create_pool(
        database="agora", user="postgres", password="pg")

    yield

    # On server shutdown (cleanup)
    await app['pg_pool'].close()


def get_app_documentation(app):
    template = """
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <style>
    body {{max-width: 800px; margin: 0 auto;}}
    dt {{font-weight: bold;}}
    dd {{margin: 0.25em 0 0.5em 1.5em;}}
  </style>
</head>
<body>
  <h1>Agora API Documentation</h1>
  <p>
    This page lists the API endpoints for the current deployment at
    <a href="https://agoravr.online/api/">agoravr.online</a>.
  </p>
  <h2>Authentication Notes</h2>
  <p>
    Besides <em>/authenticate</em> and <em>/register</em> all endpoints will
    require a token to authenticate with the server.
  </p>
  <p>
    After authenticating with <em>/authenticate</em> you will be provided a
    temporary token. To access the appropiate endpoints for the current user,
    send the token in the Authorization header of each request you make.
  </p>
  <h2>Endpoints</h2>
  <dl>{}</dl>
</body>
</html>"""

    doc = ""

    for router in app.router.routes():
        if router.method != "HEAD":
            doc += f"<dt>{router.method} {router.resource.canonical}</dt>\n<dd>{router.handler.__doc__}</dd>\n"

    return template.format(doc)


def get_base_app(_):
    app = web.Application()

    app["public_key"], app["private_key"] = load_keys("EmotionComedian")

    app["tokens"] = {}

    app["types"] = {
        "patient": 1,
        "clinician": 2,
        "caregiver": 3,
    }

    app.add_routes(routes)
    app.add_routes(caregiver_routes)
    app.add_routes(clinician_routes)
    app.add_routes(patient_routes)
    app.add_routes(session_routes)
    app.add_routes(user_routes)

    return app


def apply_cors(app, url):
    cors = aiohttp_cors.setup(app, defaults={
        url: aiohttp_cors.ResourceOptions(
            allow_credentials=False,
            expose_headers="*",
            allow_headers="*",
        ),
    })

    for route in app.router.routes():
        cors.add(route)

    return app


def get_app(foo):
    app = get_base_app(foo)

    app["documentation"] = get_app_documentation(app)

    storage_path = "storage"

    if not isdir(storage_path):
        mkdir(storage_path)

    app["storage_path"] = storage_path

    app.cleanup_ctx.append(setup_app)

    return app
