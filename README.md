# backend-demo

## Requirements

* [postgresql server](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
* [Python 3.8](https://www.python.org/downloads/)

I also recommend using the
[Powershell Preview](https://github.com/PowerShell/PowerShell/releases/tag/v7.0.0)
for use in Visual Studio Code on Windows.

## Generating RSA Keys

In order to work with JWT authentication, we must generate an RSA key pair.
This can be accomplished using OpenSSL:

```
openssl genpkey -algorithm RSA -out private.pem -aes-256-cbc -pass pass:password123
openssl rsa -in private.pem -pubout -out public.pem
```

## Installing Poetry

[Poetry](https://python-poetry.org/) is a project/package manager for Python-based
projects. It is used heavily in this project to manage dependencies and to run the
project's server.

To install Poetry, feel free to follow along with
[installation section](https://python-poetry.org/docs/#installation)
in the documentation. I personally used the unsuggested method of
[installing with pip](https://python-poetry.org/docs/#installing-with-pip)
on my Windows system.

## Setting Up the Environment

Using Poetry, the only setup requires is running `poetry install`. From
there, you can use `poetry shell` to open a shell in the virtual environment
or `poetry run` to run with the virtual environment.

## Running the Development Server

To run the development server:

```
poetry run python -m agora_backend dev
```

Assuming you have set up the `agora` database and it is running, the backend
server should start on port 8080.

## Running the Tests

Running the test requires setting up another database named `agora_testing`
using the same steps used for the development database. Afterwards, run the
following command (on Windows):

```
poetry run pytest .\tests
```

## Database Dumping

On Windows:

```
pg_dump -sO -U postgres agora | Out-File -FilePath .\create_schema.sql
pg_dump -a -U postgres agora | Out-File -FilePath .\create_data.sql
```

On GNU/Linux:

```
pg_dump -sO -U postgres agora > create_schema.sql
pg_dump -a -U postgres agora > create_data.sql
```
