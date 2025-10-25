# Use a more complete Python image to avoid apt-get issues
FROM python:3.11-bullseye

WORKDIR /app

# Install system dependencies required by Mediapipe/OpenCV
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        python3-dev \
        libgl1-mesa-glx \
        libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements from project folder
COPY project/requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy all project files from project folder
COPY project/ .

# Set Render port
ENV PORT 10000
EXPOSE $PORT

# Run the app
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]
# For Flask: 
CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:10000"]
