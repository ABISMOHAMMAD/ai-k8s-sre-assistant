#!/usr/bin/env bash
set -euo pipefail


# analyze.sh
# Send the collected output (scripts/output.txt) to Ollama (Llama3) and print the AI response.


SCRIPT_DIR="$(dirname "$0")"
OUTFILE="$SCRIPT_DIR/output.txt"


if [ ! -f "$OUTFILE" ]; then
echo "Run ./scripts/collect.sh first to create $OUTFILE"
exit 1
fi


if ! command -v jq >/dev/null 2>&1; then
echo "This script requires 'jq'. Please install jq and try again."
exit 1
fi


# Build a prompt wrapper, we pass the whole file as the prompt content.
PROMPT_HEADER="You are a Kubernetes SRE expert. Analyze the following collected output (metadata, logs, and describe). Provide a concise answer with:\n1) Root cause\n2) Why it happened\n3) Exact kubectl commands to fix the issue (if possible).\n\n-- Begin collected output --\n"
PROMPT_FOOTER="\n-- End collected output --\n"


# Use jq to create a proper JSON payload where the prompt is the raw file contents.
# jq -R -s reads the entire file as a raw string and sets it as the prompt value.


jq -Rn --arg header "$PROMPT_HEADER" --arg footer "$PROMPT_FOOTER" '(
input_filename as $f
) | .' 2>/dev/null || true


# Create payload: {"model":"llama3","prompt": "<header>...file contents...<footer>"}
PAYLOAD=$(jq -R -s --arg header "$PROMPT_HEADER" --arg footer "$PROMPT_FOOTER" '{model:"llama3", prompt: ($header + . + $footer)}' < "$OUTFILE")


# Send to Ollama's HTTP API. Ollama listens on localhost:11434 by default.
# Response JSON structure differs by version; this expects a top-level 'response' field with the text.


RESPONSE=$(curl -s -X POST "http://localhost:11434/api/generate" \
-H "Content-Type: application/json" \
-d "$PAYLOAD")


# Print raw response (for debugging)
# echo "$RESPONSE" | jq .


# Extract the generated text. Adjust depending on your Ollama version.
# Common fields: `response` or `choices[0].message.content` — try both.


AI_TEXT=$(echo "$RESPONSE" | jq -r '.response // .choices[0].message.content // .choices[0].content // "(no response field found)"')


printf "\n===== AI Analysis =====\n\n%s\n" "$AI_TEXT"
