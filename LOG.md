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
| 03 | git clone 输出 | ✅ [03-git-clone.png](docs/screenshots/03-git-clone.png) |
| 04a | brew 输密码 + 目录清单 | ✅ [04a-homebrew-password.png](docs/screenshots/04a-homebrew-password.png) |
| 04c | 官方源卡住，换 cunkai 镜像 | ✅ [04c-homebrew-cunkai-mirror.png](docs/screenshots/04c-homebrew-cunkai-mirror.png) |
| 04d | brew 主体成功 + BOTTLE 配置中 | ✅ [04d-homebrew-bottle-config.png](docs/screenshots/04d-homebrew-bottle-config.png) |
| 04b | brew --version 完成 | ⏳ 待补 |
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
| 14:48 | brew 安装第一次输 sudo 密码输错（密码盲打看不到） | 这是 Unix sudo 标准行为，不是 bug。看到 "Sorry, try again." 再输一次正确即可。注意慢点输，连错 3 次会锁定 |
| 15:00 | 官方 brew 安装脚本卡在 git fetch（国内访问 github 慢） | Ctrl+C 中断，换 gitee 上 cunkai/HomebrewCN 国内镜像脚本，选清华源，1-2 分钟搞定。副作用：~/.zshrc 被脚本修改 |
