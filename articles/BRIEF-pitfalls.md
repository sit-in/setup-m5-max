# BRIEF: 装机时踩的 10 个坑——国内 Mac 用户避坑指南

任务下发：2026-04-23
执行：M5 Max 上的 Claude Code

---

## 选题

《装机时踩的 10 个坑——国内 Mac 用户避坑指南》

跟第一篇《我把装一台 M5 Max 这件事，全交给了 Claude Code》组成系列：
- 第一篇是 **流程怎么走**（从 0 到 1 全实录）
- 这一篇是 **哪里会摔**（避坑指南）

## 输出位置

`articles/2026-04-23-mac-setup-10-pitfalls.md`

## 字数 + 受众

- 公众号长文，约 2500-3500 字
- 受众：国内 Mac 用户、开发者、想配新机或想看真实经验的人
- 风格：第一人称、直接、有真实数据

## 结构

```
开头钩子（1 段，约 100 字）
  → "装机省时间的关键不是按部就班，是提前知道哪里会摔"

10 个坑（每个 200-300 字，总共约 2500 字）
  每个统一结构：
    ### N. {一句话点出现象}
    
    **场景**：什么时候会遇到（一两句话描述）
    
    **错误反应**：新手会怎么做（容易踩坑的反应）
    
    **正确做法**：应该怎么处理 + 为什么
    
    **真实数据/截图**（如果 LOG.md 里有）：贴出来增加说服力

收尾（1 段，约 200-300 字）
  → 所有坑的元规律：国内开发者的"前置基础设施债"
  → 推 setup-m5-max 仓库链接
  → 微信号 / HiAPI / AIGoCode 推广（参考第一篇结尾）
```

## 10 个坑（按"严重度 × 普遍性"排序，从 LOG.md 抽）

按这个顺序写，标题用斩钉截铁的总结句：

1. **没装代理就硬装 brew 的代价：30 倍速差**
   - 素材：LOG.md "13:55 教训" + "16:?? 装代理后 1 分钟搞定"
   - 数据：30 分钟 vs 1 分钟

2. **系统代理对终端 CLI 无效**
   - 必须 export HTTP_PROXY/HTTPS_PROXY/ALL_PROXY
   - 否则 brew install / ollama pull / npm install 全失败

3. **xcode-select --install 弹窗会藏在窗口后面**
   - 涛哥原话："我找了好几分钟才看到不是在命令行确认的"
   - 解法：Cmd+Tab 切窗口找

4. **sudo 密码盲打没回显，连错 3 次锁定**
   - 涛哥实录：第一次输错看到 "Sorry, try again"
   - 慢点输

5. **brew 自带的 curl 不走系统代理**
   - 即使 export 了代理，brew install 拉某些 cask 还是会失败
   - 需要单独配置 brew 的 HTTPS_PROXY，或者直接走清华镜像

6. **Lark CDN 从新加坡下载极慢（~1MB/分钟）**
   - 阶段 1 brew bundle 卡 15 分钟下了 71MB/300MB 才放弃
   - 解法：跳过这个 cask，去 lark.com 下 DMG 直装

7. **homebrew/bundle 和 homebrew/services tap 已 deprecated**
   - Brewfile 里写 tap 会报 Error
   - 但不影响实际安装，看到 Error 不要慌

8. **swiftlint 必须等 Xcode 装完才能 brew install**
   - swiftlint 依赖完整 Xcode（不是 CLT）
   - 否则报错 "no Xcode installation found"

9. **ollama pull 大模型会断连，但支持断点续传**
   - 涛哥实录：Llama 3.3 70B 断 2 次，Qwen 2.5 72B 断 3 次
   - 看到 EOF / connection reset 不要重头来，直接重跑 ollama pull 即可

10. **OrbStack 装完需要首次 GUI 启动才能用 docker 命令**
    - 命令行 brew install --cask orbstack 之后还要打开 OrbStack.app 一次
    - 第一次启动会要权限 + 创建 docker socket

（可选第 11 条作为收尾彩蛋：**Migration Assistant 全量克隆是新机最大的浪费**——把这条放在收尾段，不算主 10 条）

## 配图占位符（写 5 张就够）

文章里合适位置插占位符（涛哥那边发布时会自动生图替换）。建议位置：

```markdown
![文章封面](gen:Cinematic illustration of a developer facing a laptop with red warning signs floating around: blocked network, password prompt, missing dialog box, slow download progress; overall mood is "things that go wrong during setup"; clean modern minimalist style; blue, red, and white palette)

（开头钩子之后，进入 10 个坑之前）

![代理是第 -1 步](gen:Minimalist illustration of two parallel network paths from a Mac to GitHub: top path has a proxy/VPN tower with fast green data flow, bottom path goes directly through "China Network" with red broken pipes; clear before/after contrast)

（坑 1 后面）

![终端代理需手动 export](gen:Split screen illustration: left side shows macOS system proxy settings checked "ON" but a terminal with shell commands failing with red X marks; right side shows the same terminal with "export HTTP_PROXY" command and green checkmarks; minimalist tech style)

（坑 2 后面）

![ollama 大模型下载断点续传](gen:Visualization of a large file download with multiple disconnect points marked with red X, but each restart picks up from where it stopped; progress bar going 0%→39%→92%→100% with arrows; LLM model icon Qwen and Llama; data flow style illustration)

（坑 9 后面）

![文章总结](gen:Minimalist infographic showing "10 pitfalls overcome" with 10 small icons in a grid representing each pitfall, all with green checkmarks; clean modern design, blue and white palette; suitable as article closing image)

（收尾之前）
```

## 风格要点

- **数据先行**：每个坑都要有具体数字（30 分钟 / 1MB/min / 89GB / 12.8 t/s 等）
- **第一人称**：用"我"、"涛哥"，不要假装客观
- **直接命名**：坑就是坑，不绕弯不和稀泥
- **吐槽合理**：可以吐槽"苹果可以改进 xcode-select 的命令行体验"，但别变成抱怨贴
- **可执行**：每个坑都要给"正确做法"，让读者读完就能用

## 收尾要点

- 元规律：国内开发者的"前置基础设施债"——代理、镜像、字体、CDN 这些每次配新机都要重做一遍
- setup-m5-max 仓库就是为了**沉淀这些前置基础设施债**，让下次配新机直接 git clone
- 推广（参考第一篇结尾节奏）：
  - Claude Max / Gemini Pro / ChatGPT Pro 订阅
  - AIGoCode.com（API 中转）
  - HiAPI.ai（图像 API，新人 50 张图免费）
  - vx: 257735 备注【AI】

## 完成后

```bash
cd ~/Documents/千里会/code/setup-m5-max
git add articles/2026-04-23-mac-setup-10-pitfalls.md
git commit -m "feat(articles): 10 pitfalls of Mac setup for China dev

Extracted from LOG.md gotchas, organized by severity × frequency.
5 image placeholders (gen: prompts) for HiAPI generation on publish."
git push
```

然后停下来汇报：
- 文章字数
- 10 个坑的最终标题
- 5 张图的占位符位置
- 你对收尾段的写法（特别是"元规律"那段你的总结角度）
