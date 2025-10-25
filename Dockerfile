FROM python:3.11-slim

WORKDIR /app

# Install system dependencies safely
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        build-essential \
        cmake \
        python3-dev \
        libgl1-mesa-glx \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements from the project folder
COPY project/requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy all project files from project folder
COPY project/ .

# Set port for Render
ENV PORT 10000
EXPOSE $PORT

# Run the app
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
# For Flask: 
CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:10000"]
