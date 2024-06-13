FROM python:3.12.2-slim-bookworm

RUN pip install poetry==1.8.3

WORKDIR /app
COPY pyproject.toml poetry.lock app.py ./
RUN poetry install

EXPOSE 9999
CMD poetry run ddtrace-run gunicorn -k gevent app:app -b 0.0.0.0:9999