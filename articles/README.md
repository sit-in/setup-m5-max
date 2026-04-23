# articles/

衍生文章目录。

setup-m5-max 这个 repo 是工具箱（SETUP.md / Brewfile / verify.sh）+ 完整实录（LOG.md / TUTORIAL.md / 14 张截图）。
基于这些素材延展出来的文章放这里。

## 文件命名约定

- `BRIEF-{slug}.md` — 任务 brief（涛哥提需求 / Claude Code 接任务）
- `{YYYY-MM-DD}-{slug}.md` — 文章成品

## 工作流

1. 涛哥写一份 `BRIEF-{slug}.md`，包含：选题、结构、要点、占位符约定、收尾要求
2. M5 Max 上的 Claude Code 读 BRIEF，按要求写 `{date}-{slug}.md`
3. commit + push 到 GitHub
4. 涛哥在 MBA 上 git pull，把成品 cp 到 social_media/wechat/drafts/
5. 跑 social_media/wechat/scripts/publish-baoyu.sh 发布

## 占位符配图（涛哥这边用 hiapi 生）

文章里要图的位置写 `![alt](gen:prompt描述)`。
publish-baoyu.sh 会自动扫描占位符 → 调 hiapi 生图 → 替换路径 → 发布。
不要在 setup-m5-max repo 里跑生图（凭证在 social_media repo），只写好 prompt 即可。

## 已有 brief

- BRIEF-pitfalls.md — 装机时踩的 10 个坑（避坑指南）
