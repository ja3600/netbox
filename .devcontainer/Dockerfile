FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

WORKDIR /tmp/netbox
COPY requirements.txt .

RUN python -m pip install --upgrade pip \
    && python -m pip install -r requirements.txt
