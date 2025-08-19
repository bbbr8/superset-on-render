import os
from flask_caching.backends.rediscache import RedisCache

# Secret & security
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "please-change-me")

# Make sure Superset uses Postgres (Render DATABASE_URL)
SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")

# Behind proxies (Render), respect X-Forwarded-* if enabled
ENABLE_PROXY_FIX = os.environ.get("ENABLE_PROXY_FIX", "true").lower() == "true"

# Redis (Render Key Value) connection info
REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))

# Caching
CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_cache_",
    "CACHE_REDIS_HOST": REDIS_HOST,
    "CACHE_REDIS_PORT": REDIS_PORT,
    "CACHE_REDIS_DB": 1,
}

# Store query results in Redis as well
RESULTS_BACKEND = RedisCache(
    host=REDIS_HOST,
    port=REDIS_PORT,
    key_prefix="superset_results_",
    db=2,
)
RESULTS_BACKEND_USE_MSGPACK = True

# Celery for async queries, alerts/reports
class CeleryConfig(object):
    broker_url = f"redis://{REDIS_HOST}:{REDIS_PORT}/0"
    result_backend = f"redis://{REDIS_HOST}:{REDIS_PORT}/2"
    imports = (
        "superset.sql_lab",
        "superset.tasks.scheduler",
    )
    worker_prefetch_multiplier = 10
    task_acks_late = True

CELERY_CONFIG = CeleryConfig

# Useful feature flags out of the box
FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "ALERT_REPORTS": True,
    "THUMBNAILS": True,
}

# Health check (Render will probe /health)
HEALTH_CHECK_THRESHOLD = 50  # leave default behavior
