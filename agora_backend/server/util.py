from functools import partial, wraps
from json import dumps

from aiohttp import web
from authlib.jose import errors, jwt

dumps_str = partial(dumps, default=str)


def custom_json_response(obj):
    return web.json_response(obj, dumps=dumps_str)


def row_response(result):
    return custom_json_response(dict(result.items()))


def row_list_response(results):
    return custom_json_response([dict(result.items()) for result in results])


def get_key_with_value(dictionary, target_value):
    for key, value in dictionary.items():
        if value == target_value:
            return key

def validate_request(request):
    try:
        authorization_value = request.headers["Authorization"]
    except KeyError:
        raise web.HTTPUnauthorized(text="No authorization header provided!")

    try:
        auth_type, auth_token = authorization_value.split(" ")
    except ValueError:
        raise web.HTTPUnauthorized(text="Invalid authorization header provided!")

    if auth_type.lower() != "bearer":
        raise web.HTTPUnauthorized(text="Invalid authentication method!")

    tokens = request.app["tokens"]

    if auth_token not in tokens.values():
        raise web.HTTPUnauthorized(text="Invalidated authentication token used!")

    claims = jwt.decode(auth_token, request.app["public_key"])

    try:
        claims.validate()
        return claims
    except errors.ExpiredTokenError:
        del request.app["tokens"][get_key_with_value(tokens, auth_token)]

        raise web.HTTPUnauthorized(text="Provided token is expired!")


def validate_token(handler):
    @wraps(handler)
    async def wrapped_handler(request):
        request["claims"] = validate_request(request)["agora"]

        return await handler(request)

    return wrapped_handler


def validate_user(*user_types):
    def wrapper(handler):
        @wraps(handler)
        async def wrapped(request):
            if request["claims"]["user_type"] not in user_types:
                raise web.HTTPForbidden(text="User type cannot access this endpoint!")

            return await handler(request)

        return wrapped

    return wrapper
