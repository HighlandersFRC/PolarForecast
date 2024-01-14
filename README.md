# PolarForecast
# Polar Forecast
PolarForecast is a website developed by highlanders FRC for performing continuous data analysis of robot performance at events across the country.


# Development

## Setup Development Environments

**Install Python Package Dependencies**
```
python3 -m venv venv
source venv/bin/activate
python3 -m pip3 install -r requirements.txt
```

**Setup Local Environment Variables**
Polar Forecast is designed to use environment variables for performing configuration and key management across a variety of deployment environments. The file sample.env contains the default values of all environment variables. Start by copying the sample.env file to .env
```
cp sample.env .env
```
Once the .env file has been created. Use a text editor to edit the environment variable values in the .env file. The environment variables can be activated using the command.
```
source .env
```
*Note: You will need to reactivate these environment variables every time a new run environment (terminal, CMD, etc) is created. If you 
### Setting up Local Development Environment (Docker)
If using docker for local development, bring up redis and mongoDB using the included docker-compose script
```
docker-compose up --build -d
```

### Setting up Local Development Environment (Non - Docker)

## Deployment Environment Notes


