from aiohttp.web import run_app
import click


from .server import apply_cors, get_app


@click.group()
def cli():
    pass


@cli.command()
@click.option("--path")
@click.option("--port")
def prod(path, port):
    run_app(get_app(), path=path, port=port)


@cli.command()
def dev():
    run_app(apply_cors(get_app(), "http://localhost:5000"))


if __name__ == "__main__":
    # run_app(get_app())
    cli()

