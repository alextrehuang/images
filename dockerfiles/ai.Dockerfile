FROM base/base-python:3.12 AS aibase

# 环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV TRANSFORMERS_CACHE=/mnt/shared/hf_cache
ENV LLM_OUTPUT_DIR=/mnt/shared/checkpoints

# 创建缓存目录
RUN mkdir -p $TRANSFORMERS_CACHE

WORKDIR /app

# 拷贝 AI 依赖 requirement
COPY ai-requirements.txt /app/ai-requirements.txt

# 升级 pip 并安装 AI Python 包
RUN python3 -m pip install --upgrade pip setuptools wheel -i https://pypi.tuna.tsinghua.edu.cn/simple \
 && pip install --no-cache-dir -r /app/ai-requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 可选模型目录
# COPY models /baked/models
# Flatten snapshots 等可选步骤可在 child image 或部署镜像里做

# aibase 本身不需要 CMD，因为它只是提供基础 AI 环境
