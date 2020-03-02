from aiohttp.web import run_app

from .server import get_app

if __name__ == "__main__":
    run_app(get_app(None))