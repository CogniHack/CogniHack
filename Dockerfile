# syntax=docker/dockerfile:1.3

FROM python:3.10 AS builder

ENV PIP_NO_CACHE_DIR=1
RUN pip install "poetry==1.4.2"

RUN python -m venv /venv
ENV VIRTUAL_ENV=/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

WORKDIR /app
COPY ["pyproject.toml", "poetry.lock", "/app/"]
RUN --mount=type=secret,id=auth,target=/root/.config/pypoetry/auth.toml \
  poetry install --no-dev --no-interaction --remove-untracked

FROM python:3.10-slim AS final

# Do not run as root in production
RUN useradd -m appuser
USER appuser

ENV PYTHONUNBUFFERED=1 \
  VIRTUAL_ENV=/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
WORKDIR /app

COPY --from=builder --chown=appuser $VIRTUAL_ENV $VIRTUAL_ENV
COPY --chown=appuser [".", "/app"]
