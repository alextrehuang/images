# python-311-m4.Dockerfile
FROM python:3.11-slim

# Environment
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV http_proxy=""
ENV https_proxy=""
ENV no_proxy="127.0.0.1,localhost"

# Use HTTPS Debian repos that match python:3.11-slim's Debian 13 (trixie) base
RUN rm -f /etc/apt/sources.list /etc/apt/sources.list.d/* \
 && echo "deb https://deb.debian.org/debian trixie main contrib non-free" > /etc/apt/sources.list \
 && echo "deb https://deb.debian.org/debian trixie-updates main contrib non-free" >> /etc/apt/sources.list \
 && echo "deb https://deb.debian.org/debian-security trixie-security main contrib non-free" >> /etc/apt/sources.list \
 && apt-get clean \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      curl \
      wget \
      libpq-dev \
      libmagic1 \
      procps \
      openjdk-21-jre-headless \
      ca-certificates \
      libffi-dev \
      libssl-dev \
      python3-dev \
 && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel
RUN python3 -m pip install --upgrade pip setuptools wheel -i https://pypi.tuna.tsinghua.edu.cn/simple
