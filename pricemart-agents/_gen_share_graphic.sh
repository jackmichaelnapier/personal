#!/usr/bin/env bash
# Generate the Gemini-illustrated section graphics for the patterns page.
# Uses Gemini 3 Pro Image Preview for text rendering + complex layout.
# Reads GEMINI_API_KEY from ~/.bash_profile.

set -u
# shellcheck source=/dev/null
source "$HOME/.bash_profile" >/dev/null 2>&1 || true

if [ -z "${GEMINI_API_KEY:-}" ] || [ "$GEMINI_API_KEY" = "paste-key-here" ]; then
  echo "ERR no_gemini_key" >&2
  exit 2
fi

cd "$(dirname "$0")/media"

MODEL="gemini-3-pro-image-preview"

# Consistent character + palette description carried into every prompt.
CHARACTER='The friendly small round robot character: round white body with soft blue-gray accents, two glowing mint-green eyes, gentle smile, small antenna. Always the SAME character across panels.'

PALETTE='Cool muted palette throughout: very light off-white background (#fafafa), soft blue-gray, mint green, light periwinkle, soft yellow accents, charcoal gray for line work. Stripe and Linear documentation illustration style. Subtle soft shadows under objects. Clean geometric flat illustration, generous whitespace, calm and orderly. No logos. Render any specified text crisply.'

gen() {
  local out="$1" prompt="$2"
  if [ -s "$out" ]; then
    echo "skip $out (already exists, $(wc -c < "$out") bytes)"
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

# SECTION 1 — The anatomy every agent shares (re-create if missing)
gen share-anatomy-illustrated.png "A clean modern square (1:1) editorial infographic on a very light off-white background (#fafafa). Title at top in bold sans-serif: \"The anatomy of an agent\". Below the title, a horizontal subtitle: \"Every working business agent has these five parts.\"

Below that, five small illustrated vignettes arranged in a vertical zig-zag sequence, connected by gentle dotted arrows. Each vignette is a small white rounded rectangle with subtle border and shadow, with a label outside it.

${CHARACTER}

The five vignettes, in order, each labelled clearly with the single word in bold dark-charcoal sans-serif and a small \"01\" \"02\" \"03\" \"04\" \"05\" number in light gray:

1. \"TRIGGER\" — the robot looking up at a small wall clock, soft yellow accent.
2. \"READ\" — the robot reading a stack of papers and a small dashboard with mint-green bars.
3. \"GUARD\" — the robot holding up a small shield, light periwinkle accent.
4. \"COMPUTE\" — the robot at a small desk with a soft yellow lightbulb glowing above its head.
5. \"POST\" — the robot launching a small paper-airplane envelope, soft blue-gray accent.

${PALETTE}" &

# SECTION 2 — Which one should you build first? (effort vs value matrix)
gen share-pick-first.png "A clean modern square (1:1) editorial infographic on a very light off-white background (#fafafa). Title at top in bold sans-serif: \"Pick the right first agent\". Subtitle: \"Plot your candidates on effort vs value. Start top-right.\"

The main visual is a large 2x2 matrix drawn as a soft rounded white rectangle divided into four quadrants by gentle lines. Each quadrant is a different soft pastel:
  - TOP-LEFT (light periwinkle): label \"High value · High effort\" in small dark-charcoal text, sub-label \"Save for later\" in lighter gray.
  - TOP-RIGHT (mint green) and clearly larger/brighter: label \"★ BUILD FIRST\" in bold dark-charcoal, sub-label \"High value, low effort\". A friendly small round robot character stands inside this quadrant pointing to a glowing star above it. ${CHARACTER}
  - BOTTOM-LEFT (soft gray): label \"Skip\" in dark-charcoal, sub-label \"Wouldn't it be cool if...\".
  - BOTTOM-RIGHT (soft yellow): label \"Maybe\" in dark-charcoal, sub-label \"Good for practice\".

Axis labels rendered along the edges: vertical left axis reads \"VALUE\" (rotated, uppercase, light gray, tracked). Horizontal bottom axis reads \"EFFORT\" (uppercase, light gray, tracked). Arrows at the ends of axes pointing outward.

${PALETTE}" &

# SECTION 3 — Twenty patterns, in production today
gen share-patterns-wall.png "A clean modern square (1:1) editorial infographic on a very light off-white background (#fafafa). Title at top in bold sans-serif: \"Twenty patterns, one robot\". Subtitle: \"The same agent anatomy, applied to different jobs across the business.\"

Below the title, a friendly playful wall-of-small-vignettes layout: a 4x3 grid of twelve tiny illustrated cards, each a small white rounded rectangle with the SAME friendly small round robot character doing a different job. ${CHARACTER}

Each card has a tiny one-word category tag pill at the top in a distinct soft pastel:
- Three cards tagged \"CUSTOMER\" in light blue pill.
- Four cards tagged \"OPS\" in mint-green pill.
- Two cards tagged \"MARKETING\" in light purple pill.
- Two cards tagged \"INTERNAL\" in light cyan pill.
- One card tagged \"FOUNDER\" in soft pink pill.

Each robot is doing one tiny activity: answering a chat bubble, classifying a return box, smiling at a review card, drawing a small revenue chart, watching a stock-shelf, sending an invoice reminder, spotting a metric spike with a magnifying glass, watching ad performance, peeking at a competitor card, writing meeting notes, reviewing a compliance checklist, holding a daily briefing card. No need to label each individually — the variety is the point.

${PALETTE}" &

# SECTION 4 — How to choose your first one, fast (5-question decision tree)
gen share-decision-tree.png "A clean modern square (1:1) editorial infographic on a very light off-white background (#fafafa). Title at top in bold sans-serif: \"Five questions before you build\". Subtitle: \"Run your shortlist through these, in order. Stop at the first 'no' and pick a different candidate.\"

Below the title, the friendly small round robot character stands at the left with a clipboard, ticking off items. ${CHARACTER}

To the right of the robot, a vertical numbered checklist of five short questions, each in its own small white rounded rectangle with a soft border and a green checkmark icon to the left:

1. \"Does it happen 3+ times a week?\"
2. \"Can I describe the data sources in one sentence?\"
3. \"Is the worst case recoverable in under an hour?\"
4. \"Can I write the exact format of the output?\"
5. \"Will I know in week one whether it's working?\"

Each rectangle has a small \"01\", \"02\", \"03\", \"04\", \"05\" number on the left in light gray. The fifth checkbox is shown with a soft mint-green check, the others outlined. A gentle dotted line connects them top to bottom.

${PALETTE}" &

# SECTION 5 — What goes wrong (pitfalls)
gen share-pitfalls.png "A clean modern square (1:1) editorial infographic on a very light off-white background (#fafafa). Title at top in bold sans-serif: \"Four ways agents fail\". Subtitle: \"Most failed agent projects make the same four mistakes. Knowing them is worth more than another tutorial.\"

Below the title, a 2x2 grid of four soft warm-toned warning cards (very light orange-cream background, soft warm border). Each card has a small caution-triangle icon at the top, a bold short title, and one line of clean explanation below in charcoal-gray sans-serif:

Top-left: \"Building an AI for the business\" — sub: \"One agent does one thing. Pick a narrow task.\" Small illustration: the SAME friendly robot looking overwhelmed under a giant tangled cloud. ${CHARACTER}

Top-right: \"Skipping the guard\" — sub: \"It will run on bad inputs. Always include a refuse-to-act rule.\" Small illustration: the robot crashing through a missing fence.

Bottom-left: \"No measurement plan\" — sub: \"Decide on day one how you'll measure hours saved by week four.\" Small illustration: the robot looking at an empty ruler.

Bottom-right: \"Letting it act on humans\" — sub: \"For agent #1, drafts only. Earn trust over weeks, not hours.\" Small illustration: the robot offering a draft note to a human silhouette.

${PALETTE}" &

wait
echo "DONE"
