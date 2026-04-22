# 截图清单 & 命名规范

每装一步就截一张，丢到 `docs/screenshots/` 即可。文档里的图片占位符会自动对应。

## 截图工具

- **Cmd+Shift+4**：框选区域截图（最常用）
- **Cmd+Shift+4 然后空格**：截单个窗口（带阴影）
- **Cmd+Shift+5**：完整截图工具栏（可以录屏）

截图默认保存到桌面，建议先在系统设置里改保存位置：

```bash
mkdir -p ~/Pictures/Screenshots
defaults write com.apple.screencapture location ~/Pictures/Screenshots
killall SystemUIServer
```

然后每装完一步，从 `~/Pictures/Screenshots/` 移到 `docs/screenshots/` 并重命名。

## 命名规范

格式：`{编号}-{描述短词}.png`

| 编号 | 文件名 | 内容 |
|------|--------|------|
| 00 | `00-three-machines.png` | 三机分工示意图 / 三台机器并排照片 |
| 00b | `00b-todesk.png` | ToDesk 从 MBA 远程控制 M5 Max 的画面 |
| 01 | `01-filevault.png` | FileVault 开启界面 |
| 02 | `02-xcode-clt-installing.png` | Xcode CLT 下载进度（点 Install 后） |
| 03 | `03-git-clone.png` | git clone 命令 + 输出 |
| 04 | `04-homebrew-done.png` | brew --version 输出 |
| 05 | `05-claude-code-first-run.png` | Claude Code 首次启动 |
| 06 | `06-handoff-to-claude.png` | 在 Claude Code 里输入 prompt |
| 07 | `07-brew-bundle-progress.png` | brew bundle 跑到一半 |
| 08 | `08-stage1-verify.png` | git/node/python/docker 版本号 |
| 09 | `09-ollama-pull-70b.png` | ollama pull 显示下载进度 |
| 10 | `10-llama-first-chat.png` | Llama 70B 第一次对话 |
| 11 | `11-xcode-appstore.png` | App Store 下载 Xcode |
| 12 | `12-tar-handover.png` | tar 打包后 ls -lh |
| 13 | `13-ssh-verify.png` | ssh -T github.com 成功 |
| 14 | `14-verify-all-green.png` | verify.sh 全绿 |
| 15 | `15-llama-codegen.png` | Llama 70B 写代码 |
| 16 | `16-flux-first-image.png` | Flux 生成的第一张图 |
| 17 | `17-whisper-transcription.png` | Whisper 转录输出 |

## 配图原则

1. **终端截图**：iTerm2 用透明背景或纯黑底，字体调大到 14pt+
2. **GUI 截图**：用窗口截图（Cmd+Shift+4 + 空格），自带阴影更高级
3. **进度条/数字**：选取关键瞬间，不要拍模糊或还在加载中的状态
4. **敏感信息**：账号 / token / 邮箱 / 私钥路径要打码
5. **文件大小**：单图 < 1MB（公众号要求），太大用 ImageOptim 压一下

## 配图工作流

```bash
# 方案 A：装一步截一张，立刻挪过来
mv ~/Pictures/Screenshots/截屏*.png ~/Documents/千里会/code/setup-m5-max/docs/screenshots/01-filevault.png

# 方案 B：装完所有再批量挪
ls ~/Pictures/Screenshots/  # 按时间顺序排好
# 然后手动重命名
```

## 发布到公众号时

- `wechat/scripts/publish.py` 会自动把本地图片传到 mmbiz.qpic.cn
- 不需要先传 R2 / 别的图床
- 直接 `python publish.py setup-m5-max/TUTORIAL.md --cover docs/screenshots/00-three-machines.png`
