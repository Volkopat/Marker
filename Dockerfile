FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Eastern

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.9 python3.9-dev python3.9-distutils \
    git \
    build-essential \
    libtesseract-dev \
    tesseract-ocr \
    tesseract-ocr-eng \
    ghostscript \
    libsm6 libxext6 libxrender-dev \
    libgl1-mesa-glx \
    ocrmypdf \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python3.9 \
    && pip3.9 install --upgrade pip \
    && pip3.9 install poetry

# Configure SSL for Python requests
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Set the working directory in the container
WORKDIR /app

# Copy Python dependency files
COPY pyproject.toml poetry.lock ./

# Lock the project dependencies
RUN poetry lock --no-update

# Install Python dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --only main

# Copy the rest of the application
COPY . .

# Set environment variables for the application
ENV TORCH_DEVICE=cuda \
    INFERENCE_RAM=16 \
    OCR_ENGINE=ocrmypdf \
    TESSDATA_PREFIX=/usr/share/tesseract-ocr/4.00/tessdata

# Expose the port the app runs on
EXPOSE 7860

# Command to run the app
CMD ["poetry", "run", "python3.9", "run.py"]
