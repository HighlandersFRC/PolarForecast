FROM python:3.10.2

# Set working directory
WORKDIR /code

# Copy requirements file to the container
COPY ./requirements.txt /code/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy the FastAPI app to the container
COPY ./API /code/app

# Copy the rest of the project files
COPY ./ /code/

# Set PYTHONPATH environment variable
ENV PYTHONPATH=/code/app

# Expose port 8000 for FastAPI
EXPOSE 8000

# Run FastAPI using Uvicorn, binding to 0.0.0.0 to make it accessible from outside the container
CMD ["uvicorn", "app.api:app", "--host", "0.0.0.0", "--port", "8000"]
