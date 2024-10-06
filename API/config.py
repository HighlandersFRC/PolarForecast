import os
import sys
import logging
from loguru import logger
import redis

JSON_LOGS = True if os.environ.get("JSON_LOGS", "0") == "1" else False
TBA_API_URL = "https://www.thebluealliance.com/api/v3/"
class InterceptHandler(logging.Handler):
    def emit(self, record):
        # get corresponding Loguru level if it exists
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # find caller from where originated the logged message
        frame, depth = sys._getframe(6), 6
        while frame and frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


def setup_logging(log_level):
    # intercept everything at the root logger
    logging.root.handlers = [InterceptHandler()]
    logging.root.setLevel(log_level)

    # remove every other logger's handlers
    # and propagate to root logger
    for name in logging.root.manager.loggerDict.keys():
        logging.getLogger(name).handlers = []
        logging.getLogger(name).propagate = True

    # configure loguru
    logger.configure(handlers=[{"sink": sys.stdout, "serialize": JSON_LOGS}])



# Specify Feature Flags
MATCH_SANITIZATION = os.environ.get('PF_MATCH_SANITIZATION', True) # Specifies if the Polar Forecast API should skip matches that fail data integrity checks.
LOG_LEVEL = os.environ.get("PF_LOG_LEVEL", "INFO") # DEBUG, INFO, WARNING, ERROR, CRITICAL
# logging.basicConfig(format='%(levelname)s:     %(asctime)s %(message)s', level = logging.getLevelName(LOG_LEVEL))
setup_logging(LOG_LEVEL)



ENABLE_TBA = os.environ.get("PF_TBA_ENABLE", True) # Enable Blue ALliance
TBA_POLLING = os.environ.get("PF_TBA_POLLING", True) # Specifies if the Polar Forecast API should Poll Blue Alliance for Data.
TBA_POLLING_INTERVAL = os.environ.get("PF_TBA_POLLING_INTERVAL", 30 * 60) # Polling invterval in seconds.
TBA_API_KEY = os.environ.get("PF_TBA_API_KEY", "")
logging.info("Using TBA API Key: "+TBA_API_KEY)
if len(TBA_API_KEY) == 0:
    logging.warning("No Blue Alliance API Key Set")


ENABLE_TOA = os.environ.get("PF_TOA_ENABLE", False) # Enable Orange Alliance
TOA_POLLING = os.environ.get("PF_TOA_POLLING", False) # Species if the Polar Forecast API should Poll Orange Alliance for Data
TOA_POLLING_INTERVAL = os.environ.get("PF_TOA_POLLING_INTERVAL", 10 * 60) # Polling interval in seconds
TOA_API_KEY = os.environ.get("PF_TOA_API_KEY", "")

if len(TOA_API_KEY) == 0:
    logging.warning("No Orange Alliance API Key Set")


# REDIS Parameters
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = os.getenv("REDIS_PORT", "6379")
REDIS_PASSWORD = os.getenv("REDIS_PASSWORD", None)
def get_redis_client():
    try:
        RedisClient = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, password=REDIS_PASSWORD, ssl=True)
    except Exception as e:
        logging.error(str(e))
        logging.info("redis connection: " + REDIS_HOST + " " + REDIS_PORT + " " + REDIS_PASSWORD)
        RedisClient = None
    return RedisClient

# Mongo Parameters
MONGO_CONNECTION = os.environ.get("PF_MONGO_CONNECTION", "mongodb://localhost:27017")

APP_HOST = os.environ.get("APP_HOST", "")
ALLOW_ORIGINS = [
    "127.0.0.1:8000",
    "http://127.0.0.1:3000",
    "http://localhost:3000",
    "http://localhost:8080",
]
#Password
EDIT_PASSWORD = os.environ.get("PF_EDIT_PASSWORD", "")