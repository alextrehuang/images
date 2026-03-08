# dockerfiles/base-python.Dockerfile

# Use official Python 3.12 slim (multi-arch, works on ARM64)
FROM python:3.12-slim-bookworm AS runtime

# Environment
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV http_proxy=""
ENV https_proxy=""
ENV no_proxy="127.0.0.1,localhost"

# Use HTTPS mirrors for Debian packages
RUN rm -f /etc/apt/sources.list /etc/apt/sources.list.d/* \
 && echo "deb https://mirrors.aliyun.com/debian bookworm main contrib non-free" > /etc/apt/sources.list \
 && echo "deb https://mirrors.aliyun.com/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list \
 && echo "deb https://mirrors.aliyun.com/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list \
 && apt-get clean \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      wget \
      libpq-dev \
      libmagic1 \
      procps \
      openjdk-17-jre-headless \
      ca-certificates \
      libffi-dev \
      libssl-dev \
      python3-dev \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel
RUN python3 -m pip install --upgrade pip setuptools wheel -i https://pypi.tuna.tsinghua.edu.cn/simple