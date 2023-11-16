# Use an official Python runtime as a parent image
FROM python:3.8-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

#set the django settings module
ENV  DJANGO_SETTINGS_MODULE = politica_candidate.settings

#run migrations and collect static files
RUN python manage.py migrate
RUN python manage.py make migrations
RUN python manage.py collectstatic --noinput
RUN python manage.py createsuperuser

# Copy the application code into the container
COPY . /app/

# Expose the port that Django will run on
EXPOSE 8000

# Collect static files
RUN python manage.py collectstatic --noinput

# Apply database migrations
RUN python manage.py migrate

# Start the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "politica_candidate.wsgi:application"]
