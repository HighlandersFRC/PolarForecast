import os
import logging
# REDIS Parameters
REDIS_HOST = os.environ.get("PF_REDIS_HOST", "localhost")
REDIS_PORT = os.environ.get("PF_REDIS_PORT", 6379)
REDIS_PRIMARY_KEY = os.environ.get("PF_REDIS_PRIMARY_KEY", "")
REDIS_STRICT = os.environ.get("PF_REDIS_STRICT", False)

# Mongo Parameters
MONGO_CONNECTION = os.environ.get("PF_MONGO_CONNECTION", "mongodb+srv://admin:admin@localhost:27017/PolarForecast")

# API Access Parameters
TBA_API_KEY = os.environ.get("PF_TBA_API_KEY", "")
TOA_API_KEY = os.environ.get("PF_TOA_API_KEY", "")

if TBA_API_KEY == "":
    logging.warn("No API KEY for Blue alliance specified.")

if TOA_API_KEY == "":
    logging.warn("No API Key for the Orange alliance specified.")



# Specify Feature Flags 
TBA_POLLING = os.environ.get("PF_TBA_POLLING", True) # Specifies if the Polar Forecast API should Poll Blue Alliance for Data.
TBA_POLLING_INTERVAL = os.environ.get("PF_TBA_POLLING_INTERVAL", 10 * 60) # Polling invterval in seconds. 
MATCH_SANITIZATION = os.environ.get('PF_MATCH_SANITIZATION', True) # Specifies if the Polar Forecast API should skip matches that fail data integrity checks. 


