#!/usr/bin/env bash
set -euo pipefail

MODEL="${1:-llama3.1:8b}"
PREDICT=512
PROMPT="Write a precise, technical summary of the Paxos consensus algorithm in ~300 tokens."

gen_once () {
  curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{
      \"model\": \"${MODEL}\",
      \"prompt\": \"${PROMPT}\",
      \"stream\": false,
      \"options\": {\"num_predict\": ${PREDICT}, \"temperature\": 0}
    }"
}

echo "Model: ${MODEL}"
echo "Warm-up (loads model and fills KV cache once)..."
gen_once >/dev/null

printf "\n%-7s %-10s %-14s %-12s %-10s\n" "Trial" "Load(ms)" "PromptEval(ms)" "Gen(ms)" "Tok/s"
for i in 1 2 3; do
  OUT="$(gen_once)"
  load_ms=$(jq -r '.load_duration/1e6' <<<"$OUT")
  pe_ms=$(jq -r '.prompt_eval_duration/1e6' <<<"$OUT")
  gen_ms=$(jq -r '.eval_duration/1e6' <<<"$OUT")
  gen_tok=$(jq -r '.eval_count' <<<"$OUT")
  tokps=$(jq -r '(.eval_count) / (.eval_duration/1e9)' <<<"$OUT")
  printf "%-7s %-10.0f %-14.0f %-12.0f %-10.1f\n" "#$i" "$load_ms" "$pe_ms" "$gen_ms" "$tokps"
done

echo -e "\nTip: TTFT ≈ load_ms + prompt_eval_ms (first token latency). End-to-end ≈ sum of all ms."
