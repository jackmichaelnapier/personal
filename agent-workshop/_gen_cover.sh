#!/usr/bin/env bash
# Generate the "book cover" hero image for the Agent Workshop guide.
# Used on the napier.me homepage Creations section as the guide thumbnail.
set -u
source "$HOME/.bash_profile" >/dev/null 2>&1 || true

cd "$(dirname "$0")/media"

MODEL="gemini-3-pro-image-preview"

PROMPT='Editorial book-cover-style illustration on a very light off-white background (#fafafa). Composition like a friendly illustrated field guide cover.

In the upper portion of the image: the title "The Agent Workshop" rendered in bold dark-charcoal sans-serif typography, large and clearly readable. Beneath it, a smaller italic line in soft periwinkle blue that reads "An illustrated field guide".

In the lower portion: the friendly small round robot character Pip (round white body with soft blue-gray accents, two glowing mint-green eyes, gentle smile, small antenna with a tiny ball on top) sits cross-legged on the ground reading an open hardcover field-guide book on its lap, looking up with a warm smile.

Around Pip, six soft pastel pattern cards float at varying heights in a gentle arc across the lower frame, each card showing one tiny abstract symbol: a clock, an envelope, a small bar chart with an up-arrow, a paper airplane, a small shield, a tiny cardboard box. The cards are connected by faint gold dotted lines weaving between them.

Cool muted palette: very light off-white background, soft blue-gray, mint green, light periwinkle, soft yellow, soft rose, charcoal gray for line work. Stripe and Linear documentation illustration style. Subtle soft shadows under Pip and under each floating card. Clean geometric flat illustration. Generous whitespace around the composition.

No watermarks. No logos other than the title text itself.'

echo "→ Generating workshop-cover.png (4:3)"
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent" \
  -H "x-goog-api-key: ${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg prompt "$PROMPT" '{
    contents: [{parts: [{text: $prompt}]}],
    generationConfig: {
      responseModalities: ["IMAGE"],
      imageConfig: {aspectRatio: "4:3", imageSize: "2K"}
    }
  }')" > .tmp_cover.json

jq -r '.candidates[0].content.parts[]? | select(.inlineData) | .inlineData.data' .tmp_cover.json | head -1 | base64 -d > workshop-cover.png
rm -f .tmp_cover.json

if [ -s workshop-cover.png ]; then
  echo "OK workshop-cover.png ($(wc -c < workshop-cover.png) bytes)"
else
  echo "ERR generation failed" >&2
  exit 1
fi
