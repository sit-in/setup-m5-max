# M5 Max 装机实战日志

> 这份是**实时流水账**——按时间顺序记录每一步真实命令、真实输出、真实现象。
> 最终的 [TUTORIAL.md](./TUTORIAL.md) 会从这里提炼。
>
> 装机时间：2026-04-22 起
> 装机机器：MacBook Pro 16寸 M5 Max 128G / 2T SSD
> 操作机器：MacBook Air 14寸 24G（通过 ToDesk 远程）

---

## 14:00 — 装 ToDesk 远程控制

**为什么先装这个**：M5 Max 屏幕在桌面右侧，键鼠也是物理切换，频繁切机器太累。装 ToDesk 让 MBA 当主前端，所有后续操作都从 MBA 远程。

**操作**：
1. M5 Max 浏览器打开 https://www.todesk.com
2. 下载 macOS 版（约 80MB）
3. 装上后注册/登录账号
4. 系统设置 → 隐私与安全性 → 屏幕录制 / 辅助功能 → 给 ToDesk 授权
5. MBA 上也装 ToDesk，用 ID + 密码连接 M5 Max

**坑**：第一次连接时会提示需要给系统授权，按提示退出 ToDesk 重启即可。

**截图**：`docs/screenshots/00b-todesk.png`（待补）

---

## 14:18 — 跑 xcode-select --install

**命令**：
```bash
xcode-select --install
```

**实际输出**：
```
sitinmax@MacBook-Pro ~ % xcode-select --install
xcode-select: note: install requested for command line developer tools
sitinmax@MacBook-Pro ~ %
```

**现象**：
- 命令瞬间返回，没有报错
- 几秒钟后 macOS 系统弹出对话框，问是否安装 Command Line Developer Tools
- 点 **Install** → 同意协议
- 进入下载界面，显示进度条 + 剩余时间约 8 分钟

**截图**：[02-xcode-clt-installing.png](docs/screenshots/02-xcode-clt-installing.png) — 下载中状态

**备注**：
- 这一步装的是 git / clang / make 等基础开发工具，约 1-2GB
- 跟 App Store 里的 Xcode 是两回事，CLT 是子集
- 完整的 Xcode 后面阶段 4 单独装

---

## 14:30 — Xcode CLT 装完，验证 ✅

**命令 + 实际输出**：
```bash
sitinmax@MacBook-Pro ~ %   xcode-select -p
/Library/Developer/CommandLineTools

sitinmax@MacBook-Pro ~ % git --version
git version 2.50.1 (Apple Git-155)
```

**意外的小发现**：装完 CLT 直接就有 git 了（v2.50.1，Apple 自己 patch 过的版本），完全不需要额外 `brew install git`。后面 Homebrew 还会装一个更新的 git，但当下要 git clone 已经足够。

**用户真实吐槽（值得写进教程的避坑提示）**：

> "安装 cmd line tool 需要 GUI 确认，我觉得苹果可以改进下，感觉不是很方便，我找了几分钟才看到不是在命令行确认的"

— 涛哥，2026-04-22

**这是个真实的体验坑**：
- 命令 `xcode-select --install` 跑完只输出 `note: install requested for command line developer tools`，**没有任何提示告诉你弹窗在哪**
- 弹窗是 macOS 系统层面弹出的，可能被其他窗口遮住、可能在另一个屏幕、可能在 ToDesk 远程会话里位置很奇怪
- 找弹窗的方法：
  - 检查 Dock 有没有蓝色弹跳的图标
  - 看屏幕右上角通知中心
  - **Cmd+Tab 切换看有没有"安装程序"窗口**
  - 实在找不到就再跑一次 `xcode-select --install`，会重新弹

**给苹果的建议**（写进教程做槽点）：
- 命令行直接给一行提示："请在屏幕上找到弹窗并点击 Install"
- 或者支持 `--accept-license --silent` 全自动模式

这种"明明是命令行，却还要 GUI 确认"的体验，是 macOS 不少地方的通病。值得作为这篇教程的一个真实小细节。

---

## 14:?? — 拉 setup-m5-max repo

**命令**：
```bash
mkdir -p ~/Documents/千里会/code
cd ~/Documents/千里会/code
git clone https://github.com/sit-in/setup-m5-max.git
cd setup-m5-max
ls
```

**预期输出**：
```
Cloning into 'setup-m5-max'...
remote: Enumerating objects: XX, done.
remote: Counting objects: 100% (XX/XX), done.
...
Receiving objects: 100% (XX/XX), XX KiB | XX MiB/s, done.

# ls 之后:
Brewfile-core   LOG.md   README.md   SETUP.md   TUTORIAL.md   ai-stack.sh   docs   verify.sh
```

**截图建议**：终端的 git clone 输出 + ls 列出文件清单

**坑预警**：
- 如果遇到 `xcrun: error: invalid active developer path` → 说明 CLT 还没装完，回去等
- 如果遇到 SSL 错误 → 网络问题，挂代理重试

**待补**：实际输出截图（保存为 `03-git-clone.png`）

---

## 14:?? — 装 Homebrew

**命令**：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**装完会提示**（**重要！必须执行**）：
```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**验证**：
```bash
brew --version
# 预期: Homebrew 4.x.x
which brew
# 预期: /opt/homebrew/bin/brew
```

**坑预警**：
- 不加 PATH 的话，新开终端 brew 命令会找不到
- 国内网络可能慢，必要时配镜像源（USTC / 清华 / 阿里）

**截图建议**：
- 安装过程中需要按 RETURN 确认那一帧
- 装完跑 `brew --version` 看到版本号那一帧（保存为 `04-homebrew-done.png`）

---

## 14:?? — 装 Claude Code

**命令**：
```bash
brew install --cask claude-code
```

**等装完**（约 1-3 分钟），跑：
```bash
claude
```

**第一次启动会**：
- 提示登录 Anthropic 账号
- 浏览器自动打开授权页
- 用你的 Claude Max 账号登录
- 授权后回到终端

**截图建议**：claude 命令第一次启动后的欢迎界面（保存为 `05-claude-code-first-run.png`）

---

## 14:?? — 把任务交给 Claude Code

在 `setup-m5-max` 目录下进入 Claude Code 后，输入：

```
按 SETUP.md 的阶段 1-6 配置这台 M5 Max。每完成一阶段告诉我让我确认再进下一阶段。
```

**截图建议**：在 Claude Code 里输入这行 prompt 的画面（保存为 `06-handoff-to-claude.png`）

---

## 后续阶段（待装）

- [ ] **阶段 1**：`brew bundle --file=Brewfile-core` 装 30 个核心工具（约 30 分钟）
- [ ] **阶段 2**：`bash ai-stack.sh` 装 AI 栈 + 拉 Llama 70B / Qwen 72B 模型（挂机数小时）
- [ ] **阶段 3**：App Store 装 Xcode（约 15GB，可提前挂着）
- [ ] **阶段 4**：从 MBA tar 打包关键配置 → AirDrop → M5 Max 解包
- [ ] **阶段 5**：跑 `bash verify.sh`，全绿才算完
- [ ] **阶段 6**：跑第一个真实任务（Llama 70B 对话 / Flux 出图 / Whisper 转录）

每完成一步，回来这里更新时间戳 + 实际输出 + 截图。

---

## 截图汇总（实时更新）

| 编号 | 文件 | 状态 |
|------|------|------|
| 00b | ToDesk MBA→M5 Max 远程 | ⏳ 待补 |
| 02 | Xcode CLT 下载中 | ✅ [02-xcode-clt-installing.png](docs/screenshots/02-xcode-clt-installing.png) |
| 03 | git clone 输出 | ⏳ 待补 |
| 04 | brew --version | ⏳ 待补 |
| 05 | Claude Code 首次启动 | ⏳ 待补 |
| 06 | 把任务交给 Claude | ⏳ 待补 |
| 07 | brew bundle 进度 | ⏳ 待补 |
| 08 | 工具版本号验证 | ⏳ 待补 |
| 09 | ollama pull 70B | ⏳ 待补 |
| 10 | Llama 第一次对话 | ⏳ 待补 |
| 11 | App Store 装 Xcode | ⏳ 待补 |
| 14 | verify.sh 全绿 | ⏳ 待补 |

---

## 实时坑记录（出问题就追加）

> 一栏一行：发生时间 / 现象 / 排查 / 解决

| 时间 | 现象 | 解决 |
|------|------|------|
| 14:18 | `xcode-select --install` 跑完没看到弹窗，找了几分钟 | 弹窗是 macOS 系统层面弹的，可能被遮住或在通知中心。Cmd+Tab 找"安装程序"窗口，或重跑命令重新弹 |
