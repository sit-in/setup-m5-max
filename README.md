# M5 Max 128G 配置工具包

把一台空 M5 Max 配成"重型 AI 节点 + 主力开发机"的全套脚本与文档。

## 文件清单

| 文件 | 作用 |
|------|------|
| `SETUP.md` | 主文档，6 阶段配置指南（**先看这个**） |
| `Brewfile-core` | 核心 CLI + GUI 应用清单（`brew bundle --file=Brewfile-core`） |
| `ai-stack.sh` | AI 工具栈安装（Ollama / MLX / ComfyUI / Whisper） |
| `verify.sh` | 配置完成后的 sanity check |

## 快速开始（新机器零环境）

```bash
# 1. 装 Xcode CLT（自带 git）
xcode-select --install

# 2. 拉这个 repo
git clone https://github.com/sit-in/setup-m5-max.git
cd setup-m5-max

# 3. 装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. 装 Claude Code 并启动
brew install --cask claude-code
claude
```

进 Claude Code 后说：

> 按 SETUP.md 的阶段 1-6 配置这台 M5 Max，每完成一阶段告诉我让我确认。

详见 [SETUP.md](./SETUP.md)。

## 设计哲学

- **手动 5 分钟，自动化全部**：人类只做 GUI 操作，剩下交给 Claude Code
- **不做 Migration Assistant 全量克隆**：M5 Max 是干净的 AI 节点，不搬 MBA 的历史包袱
- **三机分工**：M5 Max（主力 + AI）/ MBA 14"（移动机）/ Mac Mini（OpenClaw 自动化）
- **Brewfile 即文档**：包列表本身就是最准确的"装了什么"
- **可重复**：未来换机 / 大版本升级，这套流程直接复用
