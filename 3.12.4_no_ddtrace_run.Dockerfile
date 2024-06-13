FROM python:3.12.4-slim-bookworm

RUN pip install poetry==1.8.3

WORKDIR /app
COPY pyproject.toml poetry.lock app.py ./
RUN poetry install

EXPOSE 9999
CMD poetry run gunicorn -k gevent app:app -b 0.0.0.0:9999