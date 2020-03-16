from asyncpg import create_pool
from pytest import fixture

from agora_backend.server import get_base_app


@fixture
async def testing_app(tmpdir):

    async def setup_app(app):
        # On server startup
        app["pg_pool"] = await create_pool(
            database="agora_testing", user="postgres", password="pg")

        yield

        # On server shutdown (cleanup)
        await app['pg_pool'].close()

    def get_app_wrapper(foo):
        app = get_base_app(foo)

        app["storage_path"] = tmpdir

        app.cleanup_ctx.append(setup_app)

        return app

    return get_app_wrapper


async def get_auth_token(client, username, password):
    auth_response = await client.post("/authenticate",
        json={"user_name": username, "user_pass": password})

    return await auth_response.text()