FROM python:3.11-bullseye

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install wheel
RUN pip install --upgrade pip setuptools wheel

# Copy and install Python dependencies
COPY project/requirements.txt .
RUN pip install -r requirements.txt

# Copy project files
COPY project/ .

ENV PORT 10000
EXPOSE $PORT

CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]
