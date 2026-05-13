#!/usr/bin/env bash
# Generate varied-format illustrations for the patterns page rebuild.
# Mix of wide 16:9 banners, 3:4 portrait, and small 1:1 category spots.
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
  local out="$1" ratio="$2" prompt="$3"
  if [ -s "$out" ]; then
    echo "skip $out ($(wc -c < "$out") bytes)"
    return 0
  fi
  echo "→ ${out} (${ratio})"
  curl -s -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent" \
    -H "x-goog-api-key: ${GEMINI_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg prompt "$prompt" --arg ratio "$ratio" '{
      contents: [{parts: [{text: $prompt}]}],
      generationConfig: {
        responseModalities: ["IMAGE"],
        imageConfig: {aspectRatio: $ratio, imageSize: "2K"}
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

# ─── WIDE BANNERS (16:9) ───────────────────────────────────────

gen hero-wide.png "16:9" "A clean modern wide editorial illustration on very light off-white background (#fafafa). NO TEXT. ${CHARACTER} On the left third of the wide frame the robot sits cross-legged on the floor reading an open hardcover field-guide book on its lap, gentle smile. To the right of the robot, spread across the rest of the wide frame, six soft pastel pattern cards float gently at varying heights, each showing one tiny abstract symbol: a clock, an envelope, a small bar chart, a small warehouse box, a paper airplane, a shield. The cards are connected by very gentle dotted lines that arc across the scene. ${PALETTE}" &

gen anatomy-flow.png "16:9" "A clean modern wide editorial illustration on very light off-white background (#fafafa). A horizontal process flow showing five labeled stages from left to right, connected by gentle dotted arrows. Each stage is a small white rounded card with a thin soft-pastel top bar and contains one simple icon and one bold word in dark-charcoal sans-serif. The five cards in order: \"01 TRIGGER\" with a clock icon (soft yellow top), \"02 READ\" with a stack of lines icon (mint green top), \"03 GUARD\" with a shield icon (light periwinkle top), \"04 COMPUTE\" with a chip/processor icon (charcoal top, slightly darker), \"05 POST\" with a paper airplane icon (soft blue top). ${CHARACTER} The robot walks along under the row of cards smiling, gesturing up at one of them. ${PALETTE}" &

gen patterns-banner.png "16:9" "A clean modern wide editorial illustration on very light off-white background (#fafafa). NO TEXT. A long horizontal panorama showing six small white rounded card vignettes spread evenly across the frame, each card has a thin tinted top bar in a different soft pastel (sky blue, mint, soft purple, light cyan, soft rose, soft yellow). Inside each card the SAME friendly small round robot character is doing a different job: 1) answering a chat bubble, 2) reading a small revenue chart, 3) checking shelves of stock boxes with a clipboard, 4) sending a paper airplane envelope, 5) reviewing a checklist on a clipboard, 6) drafting a small newsletter with a pencil. ${CHARACTER} Cards are gently linked by faint dotted lines. ${PALETTE}" &

gen closing-horizon.png "16:9" "A clean modern wide editorial illustration on very light off-white background (#fafafa). NO TEXT. ${CHARACTER} The robot stands on the left third of the wide frame, with one arm extended pointing gently to the right toward a soft pastel horizon. Above the horizon a soft yellow rising sun with gentle rays. Floating gently between the robot and the horizon, three small pattern cards in a horizontal row at different heights, each containing one tiny abstract symbol (a clock, a shield, a paper airplane), connected by faint dotted lines that arc across. Calm encouraging mood. ${PALETTE}" &

# ─── PORTRAIT (3:4) ─────────────────────────────────────────────

gen questions-portrait.png "3:4" "A clean modern tall portrait editorial illustration on very light off-white background (#fafafa). NO TEXT. ${CHARACTER} The robot stands centered holding up a tall white clipboard with one hand. The clipboard shows five short horizontal lines, each preceded by a small empty soft-mint checkbox. The robot has a gentle thinking smile, with its other hand resting on its chin. Above its head floats a small soft mint thought-bubble containing three tiny gray dots. Subtle soft shadow at the robot's feet. ${PALETTE}" &

# ─── SMALL CATEGORY SPOTS (1:1) ─────────────────────────────────

gen spot-customer.png "1:1" "A clean small square icon illustration on very light off-white background (#fafafa). A circular soft sky-blue badge frame containing the friendly small round robot character peeking up from behind a single soft white chat bubble that has a tiny mint-green dot inside. Just the robot's head and shoulders visible. NO TEXT. Generous whitespace around the circular badge. ${PALETTE}" &

gen spot-ops.png "1:1" "A clean small square icon illustration on very light off-white background (#fafafa). A circular soft mint-green badge frame containing the friendly small round robot character standing beside a tiny three-bar chart with a soft mint-green up-arrow. Just the robot from the waist up visible. NO TEXT. Generous whitespace around the circular badge. ${PALETTE}" &

gen spot-marketing.png "1:1" "A clean small square icon illustration on very light off-white background (#fafafa). A circular soft light-periwinkle/purple badge frame containing the friendly small round robot character holding up a small soft white envelope with a tiny mint heart on it. Just the robot from the waist up visible. NO TEXT. Generous whitespace around the circular badge. ${PALETTE}" &

gen spot-internal.png "1:1" "A clean small square icon illustration on very light off-white background (#fafafa). A circular soft cyan badge frame containing the friendly small round robot character writing on a small notepad with a tiny pencil. Just the robot from the waist up visible. NO TEXT. Generous whitespace around the circular badge. ${PALETTE}" &

gen spot-founder.png "1:1" "A clean small square icon illustration on very light off-white background (#fafafa). A circular soft rose/peach badge frame containing the friendly small round robot character beside a tiny coffee mug with steam, holding a small briefing card. Just the robot from the waist up visible. NO TEXT. Generous whitespace around the circular badge. ${PALETTE}" &

wait
echo "DONE"
