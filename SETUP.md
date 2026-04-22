# M5 Max 128G 16寸 — 从 0 到 1 配置指南

**机器定位**：本地 AI 重型计算节点 + 主力开发机
**配置策略**：手动 5 分钟把 Claude Code 装上 → 剩下的全交给 Claude Code 跑

---

## 总体路线图

```
阶段 0：手动起步（5 分钟）       <- 你亲自操作
   ↓
阶段 1：让 Claude Code 接管      <- 把 SETUP.md 喂给它
   ↓
阶段 2-6：自动化执行            <- Claude Code 按下面清单跑
```

**核心原则**：
- 不做 Migration Assistant 全量克隆（避免把 MBA 的历史包袱搬过来）
- M5 Max 是"干净的 AI 节点"，MBA 继续做移动机
- 每装完一组就验证，不一口气装完再调

---

## 阶段 0：手动起步（5 分钟，必须亲自操作）

### 0.-1 （**最重要**）先把网络代理装上

**这是国内用户的第一步，不是"可选"**。

如果你能直接稳定访问 github.com / githubusercontent.com / formulae.brew.sh，跳过这节。

否则：先在 M5 Max 上装好你常用的代理工具（任意一个：Clash / Surge / Stash / Loon / V2Box / Quantumult X 等），并确认终端里能稳定 `curl -I https://github.com` 返回 200。

**不装代理的代价**：
- Homebrew 官方源 `git fetch` 直接卡死
- 后面所有 `brew install` 拉 bottle 极慢
- ollama / huggingface 拉模型基本不可用
- npm / pip 全球源都慢

替代方案（不能/不愿用代理）：全程用国内镜像（cunkai 装 brew、阿里 npm 镜像、清华 pypi、HuggingFace 国内镜像等）。能跑通，但每个工具都要单独配，**整体多花 30-60 分钟**。

**强烈建议**：装机第一件事就把代理打开。

### 0.0 （推荐）装 ToDesk 远程控制

让你坐在老机器（MBA）上远程操作新机器（M5 Max），后面所有步骤都更舒服。

- 在 M5 Max 上下载安装 https://www.todesk.com
- 设置安全密码 + 开机自启 + 授予屏幕录制和辅助功能权限
- MBA 上也装一个，输入 M5 Max 的远程 ID 即可接管

> 比 macOS 原生屏幕共享更稳，跨网络也能用。

### 0.1 系统初始化（GUI 操作）

- [ ] 开机走完 Setup Assistant
- [ ] 登录 Apple ID（用日常那个）
- [ ] 开启 FileVault 全盘加密（System Settings → Privacy & Security → FileVault）
- [ ] 触控板启用三指拖移（Accessibility → Pointer Control → Trackpad Options）
- [ ] 关闭"自动调整亮度"，外接显示器场景下不爽
- [ ] 设置主机名：`scutil --set HostName m5max-richard` （之后跑）

### 0.2 装 Xcode Command Line Tools

```bash
xcode-select --install
```

弹窗点 Install，等装完（约 5-10 分钟）。

### 0.3 装 Homebrew

**国内网络强烈推荐用 cunkai 镜像脚本**（见 LOG.md "15:00 — 官方源卡住"段落，详细记录了为什么）：

到 gitee 搜 `cunkai/HomebrewCN`，README 里有一行 `curl ... | bash` 命令，跑完会让你选源，**选 1（清华大学）**。

> 国外网络/翻墙环境可以走官方：`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

装完按提示**把 brew 加进 PATH**（Apple Silicon 是 `/opt/homebrew/bin/brew shellenv`）：

```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

> ⚠️ cunkai 脚本会自动改 `~/.zshrc`（加镜像源环境变量），以后从老机器搬 `.zshrc` 时要手动 merge，不能直接覆盖。

### 0.4 装 Claude Code

```bash
brew install --cask claude-code
```

装完跑一次：
```bash
claude
```
按提示登录 Anthropic 账号（用 Claude Max 那个）。

### 0.5 拉这份配置文档过来

```bash
mkdir -p ~/Documents/千里会/code
cd ~/Documents/千里会/code
git clone https://github.com/sit-in/setup-m5-max.git
cd setup-m5-max
```

> 这一步**在装 Homebrew 之前**也能跑——Xcode CLT 已经自带 git。
> repo 是 public 的，不需要认证。

### 0.6 启动 Claude Code 接管

```bash
cd ~/Documents/千里会/code/setup-m5-max
claude
```

进 Claude Code 后，输入：

> 帮我按 SETUP.md 的阶段 1-6 配置这台 M5 Max。每完成一阶段告诉我，让我确认再进下一阶段。

✅ 阶段 0 结束。下面交给 Claude Code。

---

## 阶段 1：开发工具链（Brewfile 一键装）

```bash
brew bundle --file=Brewfile-core
```

**Brewfile-core** 内容见同目录文件，包含：

| 类别 | 内容 |
|------|------|
| Shell | starship, zsh-autosuggestions, zsh-syntax-highlighting |
| 核心 CLI | git, gh, jq, ripgrep, fd, bat, eza, fzf, zoxide, tmux |
| 编辑器 | neovim |
| 网络 | curl, wget, httpie, mtr |
| 文件 | rsync, rclone, p7zip, unar |
| Python 工具链 | uv, pyenv |
| Node 工具链 | fnm（替代 nvm，更快） |
| 多语言版本管理 | mise |
| 容器 | orbstack（Docker Desktop 的 Apple Silicon 替代品，快 3-5 倍） |
| GUI 应用 | Cursor, VSCode, Raycast, 1Password, iTerm2, Rectangle, Stats |
| 浏览器 | Chrome, Arc |
| 工作流 | Notion, Telegram, Lark（飞书国际版，团队用） |
| 字体 | JetBrains Mono Nerd Font, SF Pro |

**验证**：
```bash
git --version && node --version && python3 --version && docker --version
```

---

## 阶段 2：AI 工具栈（M5 Max 专属）

```bash
bash ai-stack.sh
```

装：
- **Ollama**：本地 LLM 跑 Llama 3.3 70B / Qwen 2.5 72B
- **llama.cpp**：底层推理引擎，做量化和裁剪
- **MLX**：Apple 官方机器学习框架（M 系列芯片专属，比 PyTorch 快）
- **ComfyUI** + Flux 模型：本地出图
- **Whisper.cpp**：语音转录
- **HuggingFace CLI**：模型下载

**预下载几个常用模型**（约 100GB）：
- Llama 3.3 70B Q4 (~40GB)
- Qwen 2.5 72B Q4 (~40GB)
- Flux.1 Dev (~24GB)
- Whisper Large v3 (~3GB)

> ⚠️ 模型下载要时间，建议挑一个晚上挂着跑。脚本里我会做断点续传。

**验证**：
```bash
ollama run llama3.3 "用一句话介绍你自己"
```

---

## 阶段 3：iOS 开发环境

不能 brew 装，必须从 App Store。

- [ ] App Store 装 Xcode（约 15GB，挂着）
- [ ] 装完跑 `sudo xcodebuild -license accept`
- [ ] 装 iOS Simulator（Xcode → Settings → Platforms）
- [ ] 装 CocoaPods：`brew install cocoapods`
- [ ] 装 SwiftLint / SwiftFormat：`brew install swiftlint swiftformat`

**Apple Developer 账号**：
- [ ] Xcode → Settings → Accounts → 登录 Apple ID
- [ ] 配置签名证书（让 Xcode 自动管理）

**验证**：
```bash
xcodebuild -version
```

---

## 阶段 4：恢复个人配置（从 MBA 选择性搬）

**不要 rsync 整个 home 目录**。只搬这 7 样：

### 4.1 从 MBA 拿出来这些文件

在 MBA 上打包：
```bash
cd ~
tar czf m5-handover.tgz \
  .ssh/ \
  .gitconfig \
  .zshrc \
  .zprofile \
  .claude/ \
  .config/ \
  Library/Application\ Support/Claude/
```

AirDrop 到 M5 Max。

### 4.2 在 M5 Max 上展开

```bash
cd ~
tar xzf ~/Downloads/m5-handover.tgz
chmod 600 ~/.ssh/id_*
```

### 4.3 验证 SSH / git

```bash
ssh -T git@github.com
git config --get user.email
```

### 4.4 重要 repo 手动 clone（不要整盘搬 ~/Documents）

按你的项目优先级（参考 `social_media/context/01-projects.md`），手动 clone 现金流 + 影响力层的活跃 repo：

```bash
mkdir -p ~/Documents/千里会/code/website
cd ~/Documents/千里会/code/website
git clone <social_media>
git clone <AIGoCode>
git clone <PayForChat>
git clone <HiAPI>
git clone <saasany>
# 沉睡区的项目用到再 clone
```

### 4.5 1Password / iCloud / Notion / 飞书

直接登账号，云端拉。**不要**搬本地数据库文件。

---

## 阶段 5：最后一公里

### 5.1 Claude Code 配置

`~/.claude/` 已经从 MBA 搬过来了（包含 memory、skills、CLAUDE.md）。验证：

```bash
ls ~/.claude/
claude --version
```

如果有 MCP 服务器需要重新登录，按提示走。

### 5.2 微信公众号 / 飞书 / OpenClaw 这些工作流账号

按 `social_media/context/20-workflow.md` 里写的工具清单，逐个登录：
- Telegram Desktop
- Notion
- 飞书 / Lark
- Claude / ChatGPT / Gemini 桌面 app（如果用）

### 5.3 系统偏好微调

```bash
# 显示所有文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder 显示路径栏
defaults write com.apple.finder ShowPathbar -bool true

# 截图改保存到 ~/Pictures/Screenshots
mkdir -p ~/Pictures/Screenshots
defaults write com.apple.screencapture location ~/Pictures/Screenshots

# 关闭键盘按住自动重复（让 vim 模式更顺）
defaults write -g ApplePressAndHoldEnabled -bool false

killall Finder SystemUIServer
```

---

## 阶段 6：验证清单（跑一遍 sanity check）

```bash
bash verify.sh
```

应该全绿。失败项让 Claude Code 帮你定位。

---

## 完成后该做的事

- [ ] 把这份 SETUP.md push 到 GitHub（下次配新机直接 clone）
- [ ] 在 M5 Max 上更新 `~/.claude/CLAUDE.md` 里的"主力机"段落，加上日期和实际配置
- [ ] 把 MBA 的工作流改成"移动机"角色（不再装新工具，已有的留着）
- [ ] 跑一次 Llama 70B + Flux 出图，验证 128G 内存的真实收益

---

## 为什么这么设计

- **手动 5 分钟 + 自动化全部**：把人类需要做的 GUI 操作集中在阶段 0，剩下让 Claude Code 跑
- **Brewfile 而不是手动装**：未来配新机一行命令，且包列表本身就是文档
- **不全量迁移**：M5 Max 的角色是"干净 AI 节点"，搬历史包袱违背设计
- **分阶段验证**：每段装完跑测试，出问题第一时间定位
- **可重复**：将来 macOS 大版本升级 / 换机，这套流程都能直接复用
