#!/usr/bin/env bash
# M5 Max 配置验证脚本
# 用法: bash verify.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

check() {
  local desc=$1
  local cmd=$2
  if eval "$cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $desc"
    PASS=$((PASS+1))
  else
    echo -e "${RED}✗${NC} $desc  ${YELLOW}($cmd)${NC}"
    FAIL=$((FAIL+1))
  fi
}

warn() {
  local desc=$1
  local cmd=$2
  if eval "$cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $desc"
    PASS=$((PASS+1))
  else
    echo -e "${YELLOW}⚠${NC} $desc  ${YELLOW}(建议开启)${NC}"
    WARN=$((WARN+1))
  fi
}

echo "=== 系统 ==="
check "macOS 版本 ≥ 26"        "[[ $(sw_vers -productVersion | cut -d. -f1) -ge 26 ]]"
check "芯片是 Apple Silicon"   "uname -m | grep -q arm64"
check "Xcode CLT"             "xcode-select -p"
warn "FileVault 已开启"         "fdesetup status | grep -q 'On'"

echo ""
echo "=== 包管理 ==="
check "Homebrew"              "command -v brew"
check "brew 路径正确"          "[[ \"$(brew --prefix)\" == \"/opt/homebrew\" ]]"

echo ""
echo "=== 核心 CLI ==="
for tool in git gh jq rg fd bat eza fzf zoxide tmux nvim httpie rclone uv mise; do
  check "$tool"               "command -v $tool"
done

echo ""
echo "=== 编程语言 ==="
check "Node.js"               "command -v node"
check "Python 3"              "command -v python3"

echo ""
echo "=== 容器 ==="
check "OrbStack 已装"          "[[ -d /Applications/OrbStack.app ]]"
check "docker 命令可用"         "command -v docker"

echo ""
echo "=== AI 栈 ==="
check "Ollama"                "command -v ollama"
check "Ollama 服务运行中"       "pgrep -q ollama"
check "llama.cpp"             "command -v llama-cli"
check "whisper.cpp"           "command -v whisper-cli"
check "MLX 环境存在"            "[[ -d ~/Documents/千里会/code/ai-workspace/mlx-env ]]"

echo ""
echo "=== GUI 应用 ==="
for app in Cursor "Visual Studio Code" Raycast 1Password iTerm Telegram Notion LarkSuite; do
  check "$app.app 已装"        "[[ -d \"/Applications/$app.app\" ]]"
done

echo ""
echo "=== 个人配置 ==="
check ".ssh 目录"              "[[ -d ~/.ssh ]]"
check "id_* 私钥存在"           "ls ~/.ssh/id_* >/dev/null 2>&1"
check ".gitconfig"            "[[ -f ~/.gitconfig ]]"
check "git user.email 已设"    "git config --get user.email"
check ".claude 配置"            "[[ -d ~/.claude ]]"
check "Claude Code 命令"        "command -v claude"

echo ""
echo "=== iOS 开发（可选）==="
check "Xcode 已装"             "[[ -d /Applications/Xcode.app ]]"
check "xcodebuild 可用"        "command -v xcodebuild"
check "CocoaPods"             "command -v pod"
check "SwiftLint"             "command -v swiftlint"

echo ""
echo "=== 总结 ==="
echo -e "${GREEN}PASS: $PASS${NC}    ${RED}FAIL: $FAIL${NC}    ${YELLOW}WARN: $WARN${NC}"

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✅ 全部通过，可以开始干活了${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠️  有 $FAIL 项失败，让 Claude Code 帮你定位${NC}"
  exit 1
fi
