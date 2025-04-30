FROM python:3.10-slim

COPY . /opt/

RUN pip install -r /opt/requirements.txt

WORKDIR /opt/

RUN dbt deps
