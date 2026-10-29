FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ffmpeg \
        git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone Zou
RUN git clone https://github.com/cgwire/zou.git .
RUN git clone https://github.com/magic-lantern-workbench/zou.git .

# Install Zou
RUN pip install --upgrade pip && \
    pip install .

ENV DB_HOST=postgres
ENV DB_PORT=5432
ENV DB_DATABASE=zoudb
ENV DB_USER=zou
ENV DB_PASSWORD=zou

ENV KV_HOST=redis

ENV INDEXER_HOST=meilisearch
ENV SECRET_KEY=change-me

EXPOSE 5000

CMD ["gunicorn", "-b", "0.0.0.0:5000", "zou.app:app"]