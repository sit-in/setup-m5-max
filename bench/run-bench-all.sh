#!/bin/bash
set -euo pipefail

OUTFILE="bench-results-$(date +%Y%m%d-%H%M%S).md"
OLLAMA_BLOBS="$HOME/.ollama/models/blobs"

cat > "$OUTFILE" << 'EOF'
# M5 Max 128G 本地大模型跑分报告

> 测试时间：TIMESTAMP
> 硬件：MacBook Pro 16" M5 Max / 128GB 统一内存 / macOS 26
> 工具：llama.cpp build 8880 (Metal GPU backend)
> 测试方法：llama-bench, pp512 (输入处理) + tg128 (文本生成)

## 跑分结果

| 模型 | 大小 | 参数量 | 输入处理 pp512 (t/s) | 文本生成 tg128 (t/s) |
|------|------|--------|---------------------|---------------------|
EOF

sed -i '' "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M')/" "$OUTFILE"

bench_model() {
  local name="$1"
  local blob="$2"

  echo "[+] 跑分: $name"
  result=$(llama-bench -m "$blob" -ngl 99 -p 512 -n 128 2>&1)

  pp=$(echo "$result" | grep "pp512" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$8); print $8}')
  tg=$(echo "$result" | grep "tg128" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$8); print $8}')
  size=$(echo "$result" | grep "pp512" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$3); print $3}')
  params=$(echo "$result" | grep "pp512" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/,"",$4); print $4}')

  echo "    pp512: $pp | tg128: $tg"
  echo "| $name | $size | $params | $pp | $tg |" >> "$OUTFILE"
}

bench_model "Llama 3.2 3B Q4"      "$OLLAMA_BLOBS/sha256-dde5aa3fc5ffc17176b5e8bdc82f587b24b2678c6c66101bf7da77af9f7ccdff"
bench_model "Qwen 2.5 7B Q4"       "$OLLAMA_BLOBS/sha256-2bada8a7450677000f678be90653b85d364de7db25eb5ea54136ada5f3933730"
bench_model "Qwen2.5 Coder 32B Q4" "$OLLAMA_BLOBS/sha256-ac3d1ba8aa77755dab3806d9024e9c385ea0d5b412d6bdf9157f8a4a7e9fc0d9"
bench_model "LLaVA 34B Q4"         "$OLLAMA_BLOBS/sha256-00c39c2649c078d5ba6f74e6806c2e4ab1bce903e16105409786ef638caf24a1"
bench_model "Llama 3.3 70B Q4"     "$OLLAMA_BLOBS/sha256-4824460d29f2058aaf6e1118a63a7a197a09bed509f0e7d4e2efb1ee273b447d"
bench_model "DeepSeek R1 70B Q4"   "$OLLAMA_BLOBS/sha256-4cd576d9aa16961244012223abf01445567b061f1814b57dfef699e4cf8df339"
bench_model "Qwen 2.5 72B Q4"      "$OLLAMA_BLOBS/sha256-6e7fdda508e91cb0f63de5c15ff79ac63a1584ccafd751c07ca12b7f442101b8"

cat >> "$OUTFILE" << EOF

---

## 说明

- **pp512 (Prompt Processing)**: 处理 512 token 输入的速度，越高越好。反映"理解问题"的速度
- **tg128 (Text Generation)**: 生成 128 token 的速度，越高越好。反映"回答问题"的速度
- 所有模型均使用 Metal GPU 加速，层数全部卸载到 GPU (-ngl 99)
- 128GB 统一内存意味着 70B+ 模型完全驻留内存，无需换页

## 系统信息

\`\`\`
芯片: Apple M5 Max
内存: $(sysctl -n hw.memsize | awk '{printf "%.0f GB", $1/1024/1024/1024}')
macOS: $(sw_vers -productVersion)
llama.cpp: build 8880
Metal: MTLGPUFamilyApple10 / Metal4
\`\`\`
EOF

echo ""
echo "[+] 跑分完成！结果: $OUTFILE"
