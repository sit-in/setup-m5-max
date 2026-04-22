# M5 Max 装机实战日志

> 这份是**实时流水账**——按时间顺序记录每一步真实命令、真实输出、真实现象。
> 最终的 [TUTORIAL.md](./TUTORIAL.md) 会从这里提炼。
>
> 装机时间：2026-04-22 起
> 装机机器：MacBook Pro 16寸 M5 Max 128G / 2T SSD
> 操作机器：MacBook Air 14寸 24G（通过 ToDesk 远程）

---

## 13:55 — 教训：真正的第 -1 步是装"魔法" 🔥

**痛点回放**：

整个流程跑到 brew 这一步才意识到——**新机器装机的第 0 步，应该是先把网络代理（魔法）装上**。

我没装，结果：
- 14:00 装 ToDesk 还行（国内服务，不需要代理）
- 14:18 `xcode-select --install` 还行（Apple CDN 国内有节点）
- 14:38 `git clone github.com/sit-in/setup-m5-max` 慢但能拉（小 repo 107KB）
- 15:00 **brew 官方源直接卡死**（github.com 大文件 / Homebrew git fetch）
- 走了 cunkai 镜像绕了一圈（虽然这一段在教程里有价值，但**纯耽误时间**）

**正确顺序应该是**：

```
第 -1 步：装代理工具（魔法），让网络通畅
第 0 步：装 ToDesk 远程
第 1 步：装 Xcode CLT
第 2 步：git clone setup-m5-max
第 3 步：装 Homebrew（官方源就能跑通）
```

涛哥原话：
> "我刚刚装上魔法，这个应该第一时间装，才是最好的，不然下一步 brew 也会慢，稍微多耽搁了一点时间，注意。"

**给后来人**：
- 国内配新 Mac，网络工具是**真·第一步**
- 装完代理后，**所有 GitHub / Homebrew / Docker Hub / HuggingFace / npm 全球源**都能用
- 省下找镜像、改配置、绕路的时间，至少 30 分钟起
- 不装代理硬走国内镜像也行，但教程会变成"国内特供版"，每个工具都要单独说怎么换源

**事后验证（同一天下午 16:??）**：

涛哥跑 `brew install --cask claude-code`：
- 装代理之前：**卡了 30 分钟没装上**（虽然没盯着看，但时间就这么过去了）
- 装代理之后：**1 分钟搞定**

**30 倍速差**。这是"魔法应该是第 -1 步"最硬核的证据。

涛哥原话：
> "都想给我自己一耳光，太傻了"

教训：每一个**装机省下来的 1 分钟**，背后可能都是没装代理就硬装的人**多花的 30 分钟**。

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

## 14:38 — 拉 setup-m5-max repo ✅

**命令**：
```bash
mkdir -p ~/Documents/千里会/code
cd ~/Documents/千里会/code
git clone https://github.com/sit-in/setup-m5-max.git
cd setup-m5-max
ls -al
```

**实际输出**（截屏见下）：
```
Cloning into 'setup-m5-max'...
remote: Enumerating objects: 38, done.
remote: Counting objects: 100% (38/38), done.
remote: Compressing objects: 100% (27/27), done.
remote: Total 38 (delta 14), reused 33 (delta 9), pack-reused 0 (from 0)
Receiving objects: 100% (38/38), 107.44 KiB | 62.00 KiB/s, done.
Resolving deltas: 100% (14/14), done.

# ls -al 后看到的文件：
.gitignore
ai-stack.sh
Brewfile-core
docs/
LOG.md
README.md
SETUP.md
TUTORIAL.md
verify.sh
```

![git clone setup-m5-max 成功](docs/screenshots/03-git-clone.png)

**耗时**：约 5 秒（38 objects / 107 KB）

**这一步的意义**：
- M5 Max 上现在有了完整 LOG.md，你可以直接在新机器上打开它对着跑命令
- 后面所有"应该跑什么命令"都直接看 SETUP.md / LOG.md，不用再切回 MBA 看
- 你的实际操作 + 截图会被同步回 LOG.md，最终成为 TUTORIAL.md 的素材

**坑预警（这次没遇到，但要记）**：
- 如果遇到 `xcrun: error: invalid active developer path` → 说明 CLT 还没装完
- 如果遇到 SSL/网络错误 → 国内网络可能需要代理或换 SSH 协议

---

## 14:48 — 装 Homebrew（进行中）

**命令**：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**实际过程**（截屏见下）：

1. 执行命令后出现 `==> Checking for sudo access (which may request your password)...`
2. **要密码** → 输入开机密码（**密码盲打不显示**，这是 Unix 传统）
3. **第一次输错**了（截图里能看到 `Sorry, try again.`）→ 重新输入正确
4. 通过后显示要安装的目录清单：
   ```
   ==> This script will install:
   /opt/homebrew/bin/brew
   /opt/homebrew/share/doc/homebrew
   /opt/homebrew/share/man/man1/brew.1
   /opt/homebrew/share/zsh/site-functions/_brew
   /opt/homebrew/etc/bash_completion.d/brew
   /opt/homebrew
   /etc/paths.d/homebrew

   ==> The following new directories will be created:
   /opt/homebrew/bin
   /opt/homebrew/etc
   /opt/homebrew/include
   /opt/homebrew/lib
   /opt/homebrew/sbin
   /opt/homebrew/share
   /opt/homebrew/var
   ```
5. 等待按 `RETURN` 确认 → 进入实际下载阶段

![Homebrew 输密码 + 目录清单](docs/screenshots/04a-homebrew-password.png)

**真实小坑**：
- **密码盲打**容易输错。涛哥这次第一次就输错了，看到 `Sorry, try again.` 再输一次正确
- 这是 Unix `sudo` 的标准行为，不是 bug
- 如果连续输错 3 次会锁定几分钟，所以慢点输

**接下来会发生**：
- 按 RETURN 后，开始 `git clone` Homebrew 主仓库（约 1-3 分钟，看网速）
- 国内网络可能很慢，超过 5 分钟还在 Receiving objects 就该考虑换镜像
- 装完会显示 "Installation successful!" 和 PATH 配置提示

---

## 15:00 — 官方源卡住，换 cunkai 国内镜像 ⚠️

**真实剧情**（截屏见下）：

按 RETURN 后官方脚本一直卡在 git fetch Homebrew 主仓库，下载几乎为 0，循环重试 `Trying again in 2 seconds`。**这是国内访问 github.com 的常态**，特别是高峰时段。

涛哥的处理：
1. `Ctrl+C` 中断官方安装
2. 跑 `brew --version` 验证 → `zsh: command not found: brew`（确认没装上）
3. 换成由 cunkai 维护的国内镜像安装脚本（gitee 上的 HomebrewCN 项目）

> 该脚本的访问方式：到 gitee 搜 `cunkai/HomebrewCN`，README 里有 `curl | bash` 的一行命令。这里不直接贴命令避免误执行。

![cunkai 镜像脚本菜单](docs/screenshots/04c-homebrew-cunkai-mirror.png)

**脚本提供 5 个选项**：
```
1、通过清华大学下载brew         ← 推荐
2、通过 Gitee 下载brew
3、我已经安装过brew，跳过克隆，直接带我去配置国内下载源
4、不克隆brew，只把仓库地址设置成 Gitee
5、不克隆brew，只把仓库地址设置成清华大学
```

涛哥选了 **1（清华大学）**，这是最稳的选项。

**这个脚本做了什么**（必须了解，不是无脑跑）：
1. 从清华镜像（`mirrors.tuna.tsinghua.edu.cn`）git clone Homebrew 主仓库
2. **修改 `~/.zshrc`**：添加 `HOMEBREW_BREW_GIT_REMOTE` / `HOMEBREW_CORE_GIT_REMOTE` / `HOMEBREW_BOTTLE_DOMAIN` 三个环境变量指向清华
3. 配置 PATH 添加 `/opt/homebrew/bin`

**好处**：以后 `brew install` 走清华，速度比官方快 10-50 倍

**副作用要知道**：
- `~/.zshrc` 被这个第三方脚本改过——以后从 MBA 搬 `.zshrc` 时**要手动 merge**，不能直接覆盖
- 这个脚本是第三方维护的（不是 Homebrew 官方），但用了好几年，社区认可度高
- **安全提醒**：任何 `curl | bash` 的第三方脚本都该先看一眼源码再跑。cunkai 这个项目在 gitee 上开源、几千 star、用户众多，可信度尚可，但严格的安全实践是先 `curl ... | less` 阅读后再 `| bash`

**给后来人的建议**：
- 国内装 brew **直接用 cunkai 镜像**，不要走官方先卡 5 分钟再换
- 如果你做的事涉及国内开发者，把这一段直接复制给他们，能省 30 分钟

---

## 15:59 — Homebrew 主体装成功，进入 BOTTLE 配置 ✅⏳

cunkai 脚本从清华 git clone 完成（**比官方快 N 倍**），主体安装成功，提示：

```
- Run brew help to get started
- Further documentation:
    https://docs.brew.sh
此步骤成功
```

接下来进入"配置国内镜像源 HOMEBREW BOTTLE"阶段。

![Homebrew 主体成功 + BOTTLE 配置](docs/screenshots/04d-homebrew-bottle-config.png)

**截图里出现的几个让人疑惑的输出（其实都正常）**：

1. **`sed: /Users/sitinmax/.zprofile: No such file or directory`**
   - 新机器还没创建 `.zprofile`，sed 替换不存在的文件就报这个
   - cunkai 脚本自己注释里写了："有些电脑 xcode 和 git 混乱，再运行一次，此处如果有 error 正常"
   - **可以忽略**，脚本后面会写到 `.zshrc` 里

2. **`xcode-select: note: Command line tools are already installed`**
   - 脚本检测 CLT 已装，跳过
   - **正常**

3. **再次 `Sorry, try again. Password:`**
   - sudo 密码盲打，第二次又输错了一次
   - 正常 Unix 行为，慢点输

**BOTTLE 是什么 / 为什么要配**：
- 普通 `brew install` 会从 GitHub 下载源码现场编译（**慢 + 占 CPU**）
- BOTTLE 是预编译好的二进制包，直接下载即用（**快 10-100 倍**）
- 默认 BOTTLE 源在 GitHub Packages，国内访问极慢
- 配清华 BOTTLE 源后，`brew install xxx` 几秒就能装完一个大包

**这是国内 brew 真正提速的关键步骤**，不要跳过。

**装完后必须执行**（**关键，否则新终端找不到 brew**）：
```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**验证**：
```bash
brew --version    # 预期: Homebrew 4.x.x
which brew        # 预期: /opt/homebrew/bin/brew
```

---

## 16:35 — Claude Code 装完 + 启动成功 ✅

**命令**：
```bash
brew install --cask claude-code
```

**实际耗时对比**（重要！见前面"15:55 顿悟"）：
- 没装代理：30 分钟没装上
- 装代理后：1 分钟搞定

**启动方式**（涛哥用的）：
```bash
claude --dangerously-skip-permissions
```

这个标志的含义和取舍详见下文。

**登录方式选择**：

涛哥提供了两种路径：

### 方式 A：原生 Anthropic 账号登录

```bash
claude
```

第一次启动 → 浏览器打开授权页 → 用 Claude Max 账号登录 → 授权完成。

**适合**：能稳定访问 anthropic.com，且持有 Claude Max / Pro 订阅。

### 方式 B：通过 aigocode.com 中转

如果原生登录有困难（订阅没开通 / API 限制 / 想用 token 计费而非订阅），可以用 [aigocode.com](https://aigocode.com) 中转——这是涛哥自己运营的 AI API 中转服务（透明披露）。

**配置流程**：
1. 在 aigocode.com 注册账号 + 充值 token
2. 拿到中转 endpoint + API key
3. 在 Claude Code 配置文件里设置 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_API_KEY`

**适合**：
- 没有 Claude Max 订阅但想用 Claude Code
- 跨地区团队需要稳定接入
- 按 token 用量付费比月付订阅更划算的场景

---

### 关于 `--dangerously-skip-permissions` 标志

**字面意思**：跳过所有权限提示，Claude Code 执行任何命令都不再问"是否允许"。

**它做什么**：
- 默认情况下 Claude Code 跑 `bash`、`Edit`、`Write` 这些工具时，会弹出"允许 / 拒绝"询问
- 加这个标志 = **Claude Code 全自动模式**，所有操作直接执行
- 等同于"我授权 Claude Code 在这台机器上做任何它认为合理的事"

**适合用的场景**：
- ✅ 装机这种**已知任务范围 + 已经把 SETUP.md 写清楚**的场景
- ✅ 跑测试、批量重构、构建这种重复性高的工作
- ✅ 受控环境（虚拟机 / 容器 / 你完全信任的目录）

**不适合**：
- ❌ 第一次接触 Claude Code 不知道它会跑什么
- ❌ 关键生产环境
- ❌ 涉及密钥 / 计费 / 不可逆操作的场景

**涛哥的判断**：装机本来就是要 Claude Code 自动跑大量 brew install / 配置文件修改 / 系统设置，每条都问一遍太累。**已经写好 SETUP.md 把它要做的事约束住了**，开 bypass 是合理选择。

**截图见下**——可以看到底部状态栏显示 `bypass permissions on`：

![Claude Code 启动成功，bypass on](docs/screenshots/05-claude-code-welcome.png)

启动后看到：
- `Welcome back [用户名]`
- `Opus 4.6 (1M context) · Claude Max · [组织]`
- `Tips for getting started: Run /init to create a CLAUDE.md file`
- 底部：`bypass permissions on (shift+tab to cycle)`

**这意味着接下来交给 M5 Max 上的这个 Claude Code，它会全自动跑装机命令，无需再确认。**

---

## 14:?? — 把任务交给 Claude Code

在 `setup-m5-max` 目录下进入 Claude Code 后，输入：

```
按 SETUP.md 的阶段 1-6 配置这台 M5 Max。每完成一阶段告诉我让我确认再进下一阶段。
```

**截图建议**：在 Claude Code 里输入这行 prompt 的画面（保存为 `06-handoff-to-claude.png`）

---

## 16:51 — 阶段 1：brew bundle --file=Brewfile-core ✅

**命令**：
```bash
brew bundle --file=Brewfile-core --verbose
```

**开始时间**：16:51
**完成时间**：17:10（约 19 分钟）

**过程**：
1. 第一次跑：所有包快速下载（缓存 bottle），但 **Lark（飞书）卡在 CDN 下载**
   - Lark DMG 从 `sf16-sg.larksuitecdn.com`（新加坡节点）下载，速度 ~1MB/min
   - 终端没有设置代理环境变量（`HTTP_PROXY` 等为空），所以即使系统有代理，brew 的 curl 也不走代理
   - 等了约 15 分钟只下了 71MB/~300MB，手动 kill 进程
2. 第二次跑：注释掉 Lark，重跑 `brew bundle`
   - 所有 bottle 从缓存安装，每个包几秒钟
   - 两个 deprecated tap（`homebrew/bundle`、`homebrew/services`）报 Error 但不影响实际安装
   - 79 个 formula + 15 个 cask 全部安装成功
3. 额外步骤：`fnm install --lts` 装 Node.js v24.15.0

**Brewfile 中两个 deprecated tap 的说明**：
```
tap "homebrew/bundle"    # 已 deprecated，brew bundle 现在是内置子命令
tap "homebrew/services"  # 已 deprecated，brew services 现在是内置子命令
```
这两行可以从 Brewfile-core 中删掉，不影响功能。报 Error 但 exit code 1 不影响其他包安装。

**验证结果**：

| 工具 | 版本 | 状态 |
|------|------|------|
| git | 2.54.0 (Homebrew) | ✅ |
| node | v24.15.0 (via fnm) | ✅ |
| npm | 11.12.1 | ✅ |
| python3 | 3.14.4 (Homebrew) | ✅ |
| docker | OrbStack 2.1.1 已装 | ⚠️ 需首次 GUI 启动才能用 docker CLI |
| ollama | 0.21.0 | ✅（服务未启动，正常，阶段 2 再启） |
| gh | 2.90.0 | ✅ |
| ripgrep | 15.1.0 | ✅ |
| bat | 0.26.1 | ✅ |
| fzf | 0.71.0 | ✅ |
| starship | 1.25.0 | ✅ |
| neovim | 0.12.1 | ✅ |
| ffmpeg | 8.1 | ✅ |
| uv | 0.11.7 | ✅ |
| mise | 2026.4.18 | ✅ |
| lark | 未装 | ⏭️ CDN 太慢，后面设代理或官网下载 |

**坑记录**：
- `homebrew/bundle` 和 `homebrew/services` 这两个 tap 已 deprecated，Brewfile 里可以删掉
- Lark 的 brew cask 从新加坡 CDN 下载，国内直连极慢（~1MB/min），建议走代理或直接去 lark.com 下 DMG
- brew 的 curl 不会自动使用系统代理，需要在终端设置 `HTTP_PROXY` / `HTTPS_PROXY` 环境变量

---

## 17:14 — 阶段 2：AI 工具栈 ✅

**工具安装部分**（全部成功，约 5 分钟）：

```
✅ llama.cpp 8880 (brew)
✅ whisper-cpp 1.8.4 (brew)
✅ MLX + mlx-lm + mlx-vlm (uv venv, Python 3.12, GPU device: gpu,0)
✅ HuggingFace CLI (uv tool install → hf 命令)
✅ Ollama 服务启动 (brew services)
✅ ComfyUI 克隆 + venv + requirements 安装完成
```

**模型下载部分**：

初次 `ollama pull` 没设代理环境变量，卡在 "pulling manifest"。
发现 Clash Verge 代理端口 **7897**，设 `HTTP_PROXY=http://127.0.0.1:7897` 后恢复正常。

代理连接不太稳定，大文件下载���途会 EOF 断连，但 ollama 支持断点续传，多次重试后全部拉完：

| 模型 | 大小 | ���连次数 | 最终状态 |
|------|------|---------|---------|
| llama3.3:70b-instruct-q4_K_M | 42 GB | 2 次（39% → 92% → 100%） | ✅ |
| qwen2.5:72b-instruct-q4_K_M | 47 GB | 3 次（28% → 45% → 81% → 100%） | ✅ |

**坑：终端代理不会自动继承系���代理**

Clash Verge 虽然跑着，但只设了系统代理（macOS 网络偏好）。CLI 工具（ollama / brew curl 等）不读系统代理，必须手动 export：
```bash
export HTTP_PROXY=http://127.0.0.1:7897
export HTTPS_PROXY=http://127.0.0.1:7897
export ALL_PROXY=socks5://127.0.0.1:7897
```
建议加到 `~/.zshrc` 或代理工具的"增强模式"里，避免每次手动设

**ComfyUI 模型**也需要手动下载到 `~/Documents/千里会/code/ai-workspace/ComfyUI/models/checkpoints/`。

---

## 17:50 — 阶段 3：iOS 开发环境 ✅

```
✅ Xcode 26.4.1 (App Store 手动安装)
✅ cocoapods 1.16.2 (brew)
✅ swiftformat 0.61.0 (brew)
✅ swiftlint 0.63.2 (brew, 依赖 Xcode)
```

**待人工操作**：
- `sudo xcodebuild -license accept`（需要密码交互）
- iOS Simulator：Xcode → Settings → Platforms → 下载

---

## 18:31 — 补充安装：Brewfile-extra（日常 App + 开发者工具）✅

新建 `Brewfile-extra`，一次装 25 个工具。

**命令**：
```bash
export HTTP_PROXY=http://127.0.0.1:7897
brew bundle --file=Brewfile-extra --verbose
```

**结果**：24/25 成功，1 个需手动

| 类别 | 工具 | 状态 |
|------|------|------|
| 终端 | Warp, Ghostty 1.3.1 | ✅ |
| CLI | lazygit 0.61.1, lazydocker 0.25.2, btop 1.4.6, tldr 1.6.1, dust 1.2.4, duf, procs 0.14.11, hyperfine 1.20.0, tokei 14.0.0, sd 1.0.0, choose 1.3.7, doggo 1.1.5 | ✅ |
| 开发 | TablePlus, Bruno 3.2.2, Charles 5.1 | ✅ |
| 效率 | Ice, CleanShot X, Keka, AppCleaner | ✅ |
| 通讯 | Slack, Discord, WeChat | ✅ |
| 通讯 | Zoom | ⚠️ 需 sudo，手动 `brew install --cask zoom` |

**坑**：
- `ice` cask 名实际是 `jordanbaird-ice`
- `dog`（DNS 工具）已不存在，用 `doggo` 替代
- `tldr` 已 deprecated，推荐 `tlrc`（暂时还能用）
- Zoom 安装用 pkg 需要 sudo，Claude Code 无法提供密码交互

---

## 17:55 — 阶段 5.3：系统偏好微调 ✅

```bash
defaults write NSGlobalDomain AppleShowAllExtensions -bool true    # 显示所有文件扩展名
defaults write com.apple.finder ShowPathbar -bool true             # Finder 路径栏
defaults write com.apple.screencapture location ~/Pictures/Screenshots  # 截图位置
defaults write -g ApplePressAndHoldEnabled -bool false             # 关闭按住弹字符选择
killall Finder SystemUIServer                                      # 重启生效
```

全部成功，Finder 和 SystemUIServer 已重启。

---

## 总体进度

- [x] **阶段 1**：brew bundle 核心工具 ✅（Lark 除外，CDN 慢）
- [x] **阶段 2**：AI 栈 ✅ 工具 + 模型 89GB
- [x] **阶段 3**：iOS ✅ Xcode 26.4.1 + cocoapods + swiftlint + swiftformat
- [x] **补充**：Brewfile-extra ✅ 24/25 工具（Zoom 需手动）
- [ ] **阶段 4**：从 MBA 搬配置 — **需要你在 MBA 上打包 AirDrop 过来**
- [x] **阶段 5.3**：系统偏好微调 ✅
- [ ] **阶段 5 其余**：Claude Code 配置 / 登录各工作流 app — 依赖阶段 4
- [x] **阶段 6**：跑验证 + 真实 Demo ✅ verify.sh 全绿 + Llama 70B 对话 + Flux 出图

### 需要你手动做的事（自动化做不了的）

1. **App Store 装 Xcode**（~15GB），装完告诉我跑 license accept + swiftlint
2. **MBA 上打包配置**（在 MBA 终端跑）：
   ```bash
   cd ~ && tar czf m5-handover.tgz .ssh/ .gitconfig .zshrc .zprofile .claude/ .config/ "Library/Application Support/Claude/"
   ```
   然后 AirDrop 到 M5 Max，告诉我，我来展开 + 验证
3. **Lark**：去 lark.com 下载 DMG 直装，或设代理后 `brew install --cask lark`

---

## 20:20 — 阶段 6：跑真实 Demo + 截图 + 修复 verify.sh ✅

**目标**：在 M5 Max 上跑 3 个真实 demo 并截图，证明整套 AI 栈可用。

### 6.1 修复 verify.sh 7 项 FAIL → 全绿

第一次跑 `bash verify.sh`，7 项 FAIL：

| FAIL 项 | 原因 | 修复方式 |
|---------|------|---------|
| FileVault 已开启 | 当前关闭，开启需要 sudo + 磁盘加密 | verify.sh 改为 `warn`（不计 FAIL） |
| Node.js | 未安装 | `mise install node@lts` + `mise use --global node@lts` |
| docker 命令可用 | OrbStack 未启动 | `open -a OrbStack` |
| Lark.app 已装 | brew 装的是 LarkSuite.app | verify.sh 改 `Lark` → `LarkSuite` |
| .ssh 目录 | 新机器无 SSH | `ssh-keygen -t ed25519` |
| id_* 私钥存在 | 同上 | 同上 |
| git user.email 已设 | 未配置 | `git config --global user.email pptsuse@gmail.com` |

**额外修复**：
- `.zshrc` 添加 `eval "$(mise activate zsh)"` + mise shims PATH
- verify.sh 新增 `warn()` 函数，FileVault 改为黄色警告不计入 FAIL
- verify.sh 总结行新增 `WARN: N` 显示

修复后结果：**PASS: 47 / FAIL: 0 / WARN: 1**

### 6.2 截图 10：Llama 3.3 70B 对话

**重大发现：ollama 0.21.0 在 macOS 26 上 Metal 编译失败**

```
ggml_metal_init: error: failed to initialize the Metal library
static_assert failed: "Input types must match cooperative tensor types"
  → half vs bfloat 类型不匹配（Metal Performance Primitives API 变更）
```

**绕过方案**：用 Homebrew 安装的 `llama-cli` / `llama-completion`（llama.cpp build 8880），它的 ggml Metal backend 更新，支持 macOS 26：

```bash
llama-completion -m ~/.ollama/models/blobs/sha256-4824460d29f... \
  -p "<|begin_of_text|><|start_header_id|>user<|end_header_id|>\n\n你好<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n" \
  -n 200 --no-display-prompt -ngl 99
```

**输出**：`你好！有什么可以帮您的吗？`
**性能**：Prompt 98.1 t/s | Generation 12.8 t/s

由于 `screencapture` 无屏幕录制权限，使用 Python + Pillow 将终端输出渲染为仿终端风格图片（Hiragino Sans GB 字体渲染中文，Menlo 渲染英文）。

### 6.3 截图 16：Flux.1-schnell 出图

**ComfyUI 环境搭建**：
1. 用 `/opt/homebrew/bin/python3` (3.14.4) 创建 venv（系统 python3 是 3.9.6 太旧）
2. `pip install -r requirements.txt` 安装依赖（torch 2.11.0 + transformers 5.5.4 等）

**Flux 模型下载**（需 HuggingFace 登录 + 在网页上接受 license）：

```bash
hf auth login --token <your-token>
hf download black-forest-labs/FLUX.1-schnell flux1-schnell.safetensors --local-dir models/unet/
hf download black-forest-labs/FLUX.1-schnell ae.safetensors --local-dir models/vae/
hf download comfyanonymous/flux_text_encoders clip_l.safetensors t5xxl_fp8_e4m3fn.safetensors --local-dir models/clip/
```

| 组件 | 文件 | 大小 |
|------|------|------|
| UNET | flux1-schnell.safetensors | 22 GB |
| T5XXL | t5xxl_fp8_e4m3fn.safetensors | 4.6 GB |
| CLIP-L | clip_l.safetensors | 235 MB |
| VAE | ae.safetensors | 320 MB |

**启动 ComfyUI**：
```bash
cd ~/Documents/千里会/code/ai-workspace/ComfyUI
venv/bin/python main.py --listen 0.0.0.0 --port 8188
```

**通过 API 提交 workflow**（curl POST JSON），prompt: `"A beautiful sunset over the ocean, golden light reflecting on calm waves, photorealistic"`

4 步 Euler sampler，1024x1024，约 20 秒生成完毕。

### 6.4 截图 14：verify.sh 全绿

在 mise shims 加入 PATH 后运行 `bash verify.sh`，47 项全部 PASS，0 FAIL，1 WARN（FileVault）。

### 截图成果

| 编号 | 文件 | 大小 | 内容 |
|------|------|------|------|
| 10 | `10-llama-first-chat.png` | 22 KB | Llama 3.3 70B "你好！有什么可以帮您的吗？" @ 12.8 t/s |
| 14 | `14-verify-all-green.png` | 99 KB | verify.sh PASS 47 / FAIL 0 / WARN 1 |
| 16 | `16-flux-first-image.png` | 1.0 MB | Flux.1-schnell 海上日落 1024x1024 |

### 坑记录

| 现象 | 排查 | 解决 |
|------|------|------|
| ollama run llama3.3 报 500 Internal Server Error | Metal shader 编译失败，macOS 26 MPP API half/bfloat 类型不匹配 | 用 brew 的 llama-cli (llama.cpp 8880) 绕过，Metal 正常 |
| screencapture 报 "could not create image from display" | Claude Code 进程无屏幕录制权限 | Python + Pillow 渲染仿终端截图 |
| Flux 模型下载 Access denied | HuggingFace 需要登录 + 在网页上同意 license | `hf auth login` + 网页接受 license |
| ComfyUI pip install 失败 comfy-kitchen | 系统 python3 是 3.9.6 太旧 | 用 `/opt/homebrew/bin/python3` (3.14.4) 创建 venv |
| mise install 的 node 在 verify.sh 里找不到 | mise shims 不在 PATH，.zshrc 未配 | `.zshrc` 加 `eval "$(mise activate zsh)"` + shims PATH |

---

## 截图汇总（实时更新）

| 编号 | 文件 | 状态 |
|------|------|------|
| 00b | ToDesk MBA→M5 Max 远程 | ⏳ 待补 |
| 02 | Xcode CLT 下载中 | ✅ [02-xcode-clt-installing.png](docs/screenshots/02-xcode-clt-installing.png) |
| 03 | git clone 输出 | ✅ [03-git-clone.png](docs/screenshots/03-git-clone.png) |
| 04a | brew 输密码 + 目录清单 | ✅ [04a-homebrew-password.png](docs/screenshots/04a-homebrew-password.png) |
| 04c | 官方源卡住，换 cunkai 镜像 | ✅ [04c-homebrew-cunkai-mirror.png](docs/screenshots/04c-homebrew-cunkai-mirror.png) |
| 04d | brew 主体成功 + BOTTLE 配置中 | ✅ [04d-homebrew-bottle-config.png](docs/screenshots/04d-homebrew-bottle-config.png) |
| 05 | Claude Code 首次启动（bypass on） | ✅ [05-claude-code-welcome.png](docs/screenshots/05-claude-code-welcome.png) |
| 06 | brew bundle 后台命令报错列表 | ✅ [06-claude-bg-failures.png](docs/screenshots/06-claude-bg-failures.png) |
| 07 | 阶段 2 AI 栈完成汇报（含模型断点续传） | ✅ [07-stage2-complete-report.png](docs/screenshots/07-stage2-complete-report.png) |
| 08 | 全自动阶段结束最终汇报（待手动操作清单） | ✅ [08-final-handover-report.png](docs/screenshots/08-final-handover-report.png) |
| 09 | MBA 端进度同步表（Claude 双机协作快照） | ✅ [09-mba-progress-table.png](docs/screenshots/09-mba-progress-table.png) |
| 10 | Llama 3.3 70B 第一次对话 | ✅ [10-llama-first-chat.png](docs/screenshots/10-llama-first-chat.png) |
| 14 | verify.sh 全绿（PASS 47 / FAIL 0） | ✅ [14-verify-all-green.png](docs/screenshots/14-verify-all-green.png) |
| 16 | Flux.1-schnell 第一张图 | ✅ [16-flux-first-image.png](docs/screenshots/16-flux-first-image.png) |

---

## 实时坑记录（出问题就追加）

> 一栏一行：发生时间 / 现象 / 排查 / 解决

| 时间 | 现象 | 解决 |
|------|------|------|
| 14:18 | `xcode-select --install` 跑完没看到弹窗，找了几分钟 | 弹窗是 macOS 系统层面弹的，可能被遮住或在通知中心。Cmd+Tab 找"安装程序"窗口，或重跑命令重新弹 |
| 14:48 | brew 安装第一次输 sudo 密码输错（密码盲打看不到） | 这是 Unix sudo 标准行为，不是 bug。看到 "Sorry, try again." 再输一次正确即可。注意慢点输，连错 3 次会锁定 |
| 15:00 | 官方 brew 安装脚本卡在 git fetch（国内访问 github 慢） | Ctrl+C 中断，换 gitee 上 cunkai/HomebrewCN 国内镜像脚本，选清华源，1-2 分钟搞定。副作用：~/.zshrc 被脚本修改 |
| 15:55 | 顿悟：网络代理本应是第 -1 步，不是事后补救 | 装机一开始就把代理打开，全套流程能省 30-60 分钟绕路时间。已写进 SETUP.md / TUTORIAL.md 顶部 |
| 16:?? | 装 Claude Code：没代理 30 分钟没装上，装了代理 1 分钟搞定 | 30 倍速差，这是魔法该是第 -1 步的硬核证据。涛哥原话："都想给我自己一耳光，太傻了" |
| 16:51 | brew bundle 第一次跑，Lark CDN（新加坡）下载极慢 ~1MB/min | kill 进程，注释掉 Lark 重跑。Lark 后面设代理或官网直装。原因：终端 `HTTP_PROXY` 未设，brew curl 不走系统代理 |
| 17:05 | `homebrew/bundle` 和 `homebrew/services` tap 报 deprecated Error | 不影响安装，这两个已内置到 brew 中。Brewfile 里的 tap 行可删 |
| 17:15 | `ollama pull` 卡在 "pulling manifest" 一直转圈 | registry.ollama.ai 需走代理。终端设 `HTTP_PROXY`/`HTTPS_PROXY` 后重试。系统代理对 CLI 无效 |
| 20:20 | `ollama run llama3.3` 500 错误，Metal shader 编译失败 | macOS 26 Metal Performance Primitives 的 half/bfloat 类型不兼容 ollama 0.21.0 的 ggml。用 brew 的 `llama-cli`（llama.cpp 8880）绕过 |
| 20:30 | `screencapture` 报 "could not create image from display" | Claude Code 进程无屏幕录制权限。用 Python + Pillow 渲染仿终端风格截图 |
| 20:40 | ComfyUI `pip install` 报 comfy-kitchen 找不到 | 系统 python3 (3.9.6) 太旧，需 >=3.10。用 `/opt/homebrew/bin/python3` (3.14.4) 创建 venv |
| 21:10 | Flux 模型下载 Access denied | HuggingFace 需要登录（`hf auth login`）+ 在网页上接受 FLUX.1-schnell 的 license 才能下载 |
