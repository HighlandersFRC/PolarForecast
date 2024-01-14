import os
import sys
import logging
from loguru import logger

JSON_LOGS = True if os.environ.get("JSON_LOGS", "0") == "1" else False

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
TBA_POLLING_INTERVAL = os.environ.get("PF_TBA_POLLING_INTERVAL", 10 * 60) # Polling invterval in seconds.
TBA_API_KEY = os.environ.get("PF_TBA_API_KEY", "")

if len(TBA_API_KEY) == 0:
    logging.warning("No Blue Alliance API Key Set")


ENABLE_TOA = os.environ.get("PF_TOA_ENABLE", False) # Enable Orange Alliance
TOA_POLLING = os.environ.get("PF_TOA_POLLING", False) # Species if the Polar Forecast API should Poll Orange Alliance for Data
TOA_POLLING_INTERVAL = os.environ.get("PF_TOA_POLLING_INTERVAL", 10 * 60) # Polling interval in seconds
TOA_API_KEY = os.environ.get("PF_TOA_API_KEY", "")

if len(TOA_API_KEY) == 0:
    logging.warning("No Orange Alliance API Key Set")


# REDIS Parameters
REDIS_HOST = os.environ.get("PF_REDIS_HOST", "localhost")
REDIS_PORT = os.environ.get("PF_REDIS_PORT", 6379)
REDIS_PRIMARY_KEY = os.environ.get("PF_REDIS_PRIMARY_KEY", "")
REDIS_STRICT = os.environ.get("PF_REDIS_STRICT", False)

# Mongo Parameters
MONGO_CONNECTION = os.environ.get("PF_MONGO_CONNECTION", "mongodb+srv://admin:admin@localhost:27017/PolarForecast")
