# Use a pinned Superset image (5.0.0 as of 2025-06-23)
FROM apache/superset:5.0.0

USER root

# System deps (optional; many DB drivers need build tools)
RUN apt-get update && apt-get install -y --no-install-recommends         build-essential curl &&         rm -rf /var/lib/apt/lists/*

# Python deps: Postgres driver, Redis, Celery, Google Sheets via Shillelagh (optional)
RUN pip install --no-cache-dir         psycopg2-binary         redis         celery==5.3.6      

# Add our config on the PYTHONPATH
ENV PYTHONPATH="/app/pythonpath:$PYTHONPATH"
COPY pythonpath/superset_config.py /app/pythonpath/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/pythonpath/superset_config.py

# Init script (idempotent) + set executable
COPY scripts/init.sh /app/scripts/init.sh
RUN chmod +x /app/scripts/init.sh

# Default CMD for web service uses our init then starts Gunicorn
ENV PORT=8088
CMD ["/bin/bash", "-lc", "/app/scripts/init.sh && gunicorn -w ${GUNICORN_WORKERS:-4} -k gevent --timeout 120 -b 0.0.0.0:${PORT} 'superset.app:create_app()'"]
