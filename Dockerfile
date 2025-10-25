# Use a stable Python image
FROM python:3.11-bullseye

# Set working directory
WORKDIR /app

# Avoid interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies (required by OpenCV, Mediapipe, etc.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        python3-dev \
        libgl1-mesa-glx \
        libglib2.0-0 \
        wget \
        ffmpeg \
        git && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Copy only requirements first for caching
COPY project/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project
COPY project/ .

# Set environment variables
ENV PORT=10000
EXPOSE $PORT

# Run Flask app using Gunicorn (production-ready)
# Assuming your Flask app entry point is main.py and app is named "app"
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]
