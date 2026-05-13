#!/usr/bin/env bash
# Generate the hero + closing illustrations for the rebuilt patterns page.
set -u
# shellcheck source=/dev/null
source "$HOME/.bash_profile" >/dev/null 2>&1 || true

if [ -z "${GEMINI_API_KEY:-}" ] || [ "$GEMINI_API_KEY" = "paste-key-here" ]; then
  echo "ERR no_gemini_key" >&2
  exit 2
fi

cd "$(dirname "$0")/media"

MODEL="gemini-3-pro-image-preview"

CHARACTER='The same friendly small round robot character used throughout this guide: round white body with soft blue-gray accents, two glowing mint-green eyes, gentle smile, small antenna.'

PALETTE='Cool muted palette: very light off-white background (#fafafa), soft blue-gray, mint green, light periwinkle, soft yellow accents, charcoal gray for line work. Stripe and Linear documentation illustration style. Subtle soft shadows under objects. Clean geometric flat illustration, generous whitespace, calm and warm. No logos.'

gen() {
  local out="$1" prompt="$2"
  if [ -s "$out" ]; then
    echo "skip $out ($(wc -c < "$out") bytes)"
    return 0
  fi
  echo "→ ${out}"
  curl -s -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent" \
    -H "x-goog-api-key: ${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg prompt "$prompt" '{
      contents: [{parts: [{text: $prompt}]}],
      generationConfig: {
        responseModalities: ["IMAGE"],
        imageConfig: {aspectRatio: "1:1", imageSize: "2K"}
      }
    }')" > ".tmp_${out}.json"

  local b64
  b64=$(jq -r '.candidates[0].content.parts[] | select(.inlineData) | .inlineData.data' ".tmp_${out}.json" | head -1)
  if [ -z "$b64" ]; then
    echo "ERR no_image_in_response: $out" >&2
    head -c 600 ".tmp_${out}.json" >&2
    echo "" >&2
    rm -f ".tmp_${out}.json"
    return 1
  fi
  echo "$b64" | base64 -d > "$out"
  rm -f ".tmp_${out}.json"
  echo "OK $out ($(wc -c < "$out") bytes)"
}

# HERO — the field-guide cover. NO TEXT.
gen share-hero.png "A clean modern square (1:1) editorial illustration on a very light off-white background (#fafafa). NO TEXT in the image at all. ${CHARACTER} The robot sits cross-legged on the floor holding an open hardcover field-guide book on its lap. Floating around the robot in a gentle circle are five soft pastel pattern cards, each showing one tiny abstract symbol (a clock, an envelope, a small bar-chart, a small warehouse box, a paper airplane), connected by very gentle dotted lines. The robot looks up with a warm welcoming smile. ${PALETTE}" &

# CLOSING — your turn / one scheduled task. NO TEXT.
gen share-closing.png "A clean modern square (1:1) editorial illustration on a very light off-white background (#fafafa). NO TEXT in the image at all. ${CHARACTER} The robot stands on the right side of the frame holding out one small white index card toward the viewer. On the index card are three tiny abstract icons in a row (a clock, a shield, and a paper airplane) connected by short dotted lines. The robot has a calm encouraging smile and a slightly raised hand as if to say 'your turn'. A small soft mint speech-bubble hovers gently above the robot containing one tiny dot. ${PALETTE}" &

wait
echo "DONE"
