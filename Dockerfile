FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    PYTHONHASHSEED=0 \
    MPLCONFIGDIR=/tmp/matplotlib \
    UV_HTTP_TIMEOUT=120

# uvをコピー
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libfreetype6 \
        libpng16-16 \
        fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

# 依存関係定義ファイルを先にコピー
COPY pyproject.toml uv.lock /work/

# /opt/venv に仮想環境を作成(/workの外!)
RUN uv sync --frozen --no-cache

# /opt/venv の bin を PATH に追加
ENV PATH="/opt/venv/bin:$PATH"

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--LabApp.token=''"]