#!/usr/bin/env bash
# M5 Max AI 工具栈安装脚本
# 用法: bash ai-stack.sh
# 前置: 已经跑过 brew bundle --file=Brewfile-core （已装 ollama）

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[x]${NC} $*"; }

# ---------- 1. 验证前置 ----------
log "检查前置环境..."
command -v brew >/dev/null || { err "Homebrew 未安装"; exit 1; }
command -v ollama >/dev/null || { err "ollama 未安装，先跑 brew bundle"; exit 1; }

# ---------- 2. 装 llama.cpp（底层推理）----------
log "安装 llama.cpp..."
brew install llama.cpp || warn "llama.cpp 已存在或失败"

# ---------- 3. 装 MLX（Apple 官方 ML 框架）----------
log "安装 MLX 生态（Python 包，用 uv 装）..."
mkdir -p ~/Documents/千里会/code/ai-workspace
cd ~/Documents/千里会/code/ai-workspace
uv venv --python 3.12 mlx-env
source mlx-env/bin/activate
uv pip install mlx mlx-lm mlx-vlm
deactivate

# ---------- 4. 装 Whisper.cpp（语音转录）----------
log "安装 whisper.cpp..."
brew install whisper-cpp || warn "whisper-cpp 已存在或失败"

# ---------- 5. 装 HuggingFace CLI ----------
log "安装 HuggingFace CLI..."
uv tool install huggingface_hub --with hf_transfer

# ---------- 6. 启动 Ollama 服务 ----------
log "启动 Ollama 服务..."
brew services start ollama
sleep 3

# ---------- 7. 拉模型（按需取消注释）----------
log "拉取常用模型（约 100GB，挂着跑）..."

# 默认拉两个最常用的——其他按需取消注释
ollama pull llama3.3:70b-instruct-q4_K_M  # ~40GB
ollama pull qwen2.5:72b-instruct-q4_K_M    # ~40GB

# 可选模型（按需取消）：
# ollama pull qwen2.5-coder:32b-instruct-q4_K_M  # 编码专用
# ollama pull deepseek-r1:70b                     # 推理模型
# ollama pull nomic-embed-text                    # 向量嵌入
# ollama pull llava:34b                           # 多模态

# ---------- 8. ComfyUI（本地出图）----------
log "安装 ComfyUI（独立 venv）..."
cd ~/Documents/千里会/code/ai-workspace
if [ ! -d "ComfyUI" ]; then
  git clone https://github.com/comfyanonymous/ComfyUI.git
fi
cd ComfyUI
uv venv --python 3.12
source .venv/bin/activate
uv pip install -r requirements.txt
# Apple Silicon 用 MPS，无需额外 GPU 驱动
deactivate

warn "ComfyUI 模型权重需要手动下载到 ComfyUI/models/checkpoints/"
warn "推荐：Flux.1-dev (~24GB) — 见 https://huggingface.co/black-forest-labs/FLUX.1-dev"

# ---------- 9. 验证 ----------
log "运行验证..."
echo "--- ollama 模型 ---"
ollama list

echo "--- llama.cpp ---"
llama-cli --version || true

echo "--- whisper.cpp ---"
whisper-cli --help 2>&1 | head -3 || true

echo "--- MLX ---"
source ~/Documents/千里会/code/ai-workspace/mlx-env/bin/activate
python -c "import mlx.core as mx; print(f'MLX OK, default device: {mx.default_device()}')"
deactivate

log "AI 栈安装完成！"
log "下一步建议："
log "  1. 跑 'ollama run llama3.3' 试聊一句"
log "  2. 启动 ComfyUI: cd ~/Documents/千里会/code/ai-workspace/ComfyUI && source .venv/bin/activate && python main.py"
log "  3. 浏览器开 http://127.0.0.1:8188"
