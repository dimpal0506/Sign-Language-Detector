# Use official Python slim image
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Install system dependencies required by Mediapipe/OpenCV
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements from the 'project' folder and install
COPY project/requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy all project files from 'project' folder
COPY project/ .

# Set port for Render
ENV PORT 10000
EXPOSE $PORT

# Run the app
# For FastAPI
#CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "10000"]

# If using Flask, replace the last line with:
 CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:10000"]
