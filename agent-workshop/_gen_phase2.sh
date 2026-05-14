#!/usr/bin/env bash
# Phase 2 illustrations for /agent-workshop/.
# Generates ~85 images for Stations 2-9.
# Batched in groups of 6 in parallel to stay under rate limits.
# Idempotent: skips files that already exist.
set -u
# shellcheck source=/dev/null
source "$HOME/.bash_profile" >/dev/null 2>&1 || true

if [ -z "${GEMINI_API_KEY:-}" ] || [ "$GEMINI_API_KEY" = "paste-key-here" ]; then
  echo "ERR no_gemini_key" >&2
  exit 2
fi

cd "$(dirname "$0")/media"

MODEL="gemini-3-pro-image-preview"

PIP='Pip is the recurring mascot of this guide: a friendly small round robot character with a round white body with soft blue-gray accents, two glowing mint-green eyes, gentle smile, small antenna with a tiny ball on top. Identical proportions every time. Same character as previous illustrations in this guide.'

PALETTE='Cool muted palette: very light off-white background (#fafafa), soft blue-gray, mint green, light periwinkle, soft yellow accents, charcoal gray for line work. Stripe and Linear documentation illustration style. Subtle soft shadows under objects. Clean geometric flat illustration. Generous whitespace. NO logos. NO watermarks. NO readable text in image.'

gen() {
  local out="$1" ratio="$2" prompt="$3"
  if [ -s "$out" ]; then
    echo "skip $out"
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
  b64=$(jq -r '.candidates[0].content.parts[]? | select(.inlineData) | .inlineData.data' ".tmp_${out}.json" 2>/dev/null | head -1)
  if [ -z "$b64" ]; then
    echo "ERR no_image: $out" >&2
    head -c 400 ".tmp_${out}.json" >&2
    echo "" >&2
    rm -f ".tmp_${out}.json"
    return 1
  fi
  echo "$b64" | base64 -d > "$out"
  rm -f ".tmp_${out}.json"
  echo "OK $out ($(wc -c < "$out") bytes)"
}

batch() {
  local label="$1"
  shift
  echo "═══ Batch: $label ═══"
  for fn in "$@"; do
    eval "$fn &"
  done
  wait
  echo "─── $label done ───"
}

# ═══════════════════════════════════════════════════════════════
# STATION 2 — The five parts (Anatomy)
# ═══════════════════════════════════════════════════════════════

s2_banner() { gen s2-banner.png "16:9" "Wide editorial illustration. A workshop wall with a large white pinned paper poster on it. The poster shows 5 small white labelled cards in a horizontal row connected by gentle dotted arrows. Each card has a tiny icon: a clock, a stack of horizontal lines, a shield, a chip/processor, a paper airplane. Numbered 01 through 05 in pastel colors (yellow, mint, periwinkle, gray, blue). ${PIP} Pip stands on a small wooden stool to the left of the poster, pointing up at it with a pencil, smiling. ${PALETTE}"; }
s2_trigger() { gen s2-trigger.png "3:4" "Tall portrait editorial illustration. ${PIP} Pip stands beside a small round wall clock that floats slightly in the air at head-height, gesturing at it gently with one hand. Soft yellow accent glow around the clock. Calm friendly pose. ${PALETTE}"; }
s2_read() { gen s2-read.png "3:4" "Tall portrait editorial illustration. ${PIP} Pip holds a large magnifying glass in front of a small stack of soft-pastel papers floating in mid-air. Focused but friendly expression. Soft mint accent around the papers. ${PALETTE}"; }
s2_guard() { gen s2-guard.png "3:4" "Tall portrait editorial illustration. ${PIP} Pip holds a small mint-green shield in front of itself with both hands, in a gentle protective stance, soft confident smile. A small soft-yellow caution triangle floats off to one side. ${PALETTE}"; }
s2_compute() { gen s2-compute.png "3:4" "Tall portrait editorial illustration. ${PIP} Pip stands with one hand on its chin in a thinking pose. Above its head, a soft yellow lightbulb floats inside a small thought-bubble. ${PALETTE}"; }
s2_post() { gen s2-post.png "3:4" "Tall portrait editorial illustration. ${PIP} Pip stands with one arm extended, releasing a soft-yellow paper airplane that curves gently upward toward a small soft-mint chat bubble in the upper corner. ${PALETTE}"; }
s2_worked() { gen s2-worked-example.png "16:9" "Wide editorial illustration of a clipboard mockup taking up most of the frame. The clipboard shows five horizontal labelled rows, each with a small icon (clock, lines, shield, chip, paper airplane) followed by abstract dashes representing filled-in text (NO readable text). ${PIP} Pip stands beside the clipboard at the right edge, smiling, pointing at one row with a tiny pencil. ${PALETTE}"; }
s2_sticker() { gen sticker-anatomy-apprentice.png "1:1" "A circular souvenir sticker / badge on an off-white background. Soft mint-green circular ring frame with a small white five-pointed star at the top. Inside: ${PIP} a tiny Pip holding up a small assembled-gear icon with one hand, full body visible, smiling. Around the inner edge, a faint dotted ring pattern. Subtle drop shadow as if peeled and stuck. NO readable text. ${PALETTE}"; }

batch "Station 2" s2_banner s2_trigger s2_read s2_guard s2_compute s2_post s2_worked s2_sticker

# ═══════════════════════════════════════════════════════════════
# STATION 3 — Where they help
# ═══════════════════════════════════════════════════════════════

s3_banner() { gen s3-banner.png "16:9" "Wide editorial illustration. A bird's-eye-view of a charming small business interior viewed like an architectural cross-section. Five clearly-separated rooms in a horizontal row, each with a small Pip working at a desk. From left: a front-office reception room (chat bubbles in the air), a back-office room (paperwork and a small filing cabinet), a stockroom (shelves with neat boxes), a small studio (easel and palette), a corner office (coffee mug and a small chart). Soft pastel accent tints per room: sky blue, periwinkle, mint, soft rose, soft yellow. ${PIP} ${PALETTE}"; }
s3_customer() { gen s3-customer.png "4:3" "Editorial illustration. ${PIP} Pip sits at a small reception desk with two or three soft-pastel chat bubbles floating above the monitor. Calm, friendly, attentive pose. Soft sky-blue accent tint to the scene. ${PALETTE}"; }
s3_admin() { gen s3-admin.png "4:3" "Editorial illustration. ${PIP} Pip at a wooden desk organising a small neat stack of papers, a tiny calendar, and a small folder. A small filing cabinet drawer is partially open behind. Soft periwinkle accent tint. ${PALETTE}"; }
s3_stockroom() { gen s3-stockroom.png "4:3" "Editorial illustration. ${PIP} Pip stands beside a small warehouse shelf with a few neatly stacked cardboard boxes, holding a clipboard. Soft mint accent tint. ${PALETTE}"; }
s3_studio() { gen s3-studio.png "4:3" "Editorial illustration. ${PIP} Pip at a small drafting desk with a paintbrush in one hand and a tiny watercolour palette beside it, drawing on a small canvas. A soft envelope with a tiny heart floats nearby. Soft rose accent tint. ${PALETTE}"; }
s3_corner() { gen s3-corner-office.png "4:3" "Editorial illustration. ${PIP} Pip at a small executive desk holding a small steaming coffee mug, with a tiny briefing card propped up. A soft sun rising through a window behind. Soft yellow accent tint. ${PALETTE}"; }
s3_closing() { gen s3-closing.png "16:9" "Wide editorial illustration. Five small rooms in a horizontal row matching the previous banner, each with the same five-part flow icon overlay (clock, lines, shield, chip, paper airplane). A single gentle dotted line threads through all five rooms connecting them. ${PIP} Pip stands in front gesturing at the whole scene with both hands. ${PALETTE}"; }
s3_sticker() { gen sticker-business-scout.png "1:1" "A circular souvenir sticker / badge on an off-white background. Soft periwinkle circular ring frame with a small white star at the top. Inside: ${PIP} a tiny Pip holding a small folded paper map. Faint dotted ring border. Subtle drop shadow. NO readable text. ${PALETTE}"; }

batch "Station 3" s3_banner s3_customer s3_admin s3_stockroom s3_studio s3_corner s3_closing s3_sticker

# ═══════════════════════════════════════════════════════════════
# STATION 4 — The pattern library
# ═══════════════════════════════════════════════════════════════

s4_banner() { gen s4-banner.png "16:9" "Wide editorial illustration. A tall wooden workshop wall covered with a 4x3 grid of small white rounded specimen cards, each with a thin soft-pastel top bar in varied colors (mix of sky blue, mint, soft purple, light cyan, soft rose, soft yellow). ${PIP} Pip stands on a small stool in front of the wall, browsing one card with a magnifying glass. ${PALETTE}"; }
s4_legend() { gen s4-legend.png "4:3" "Editorial illustration of a single 'specimen card' template on a workshop bench, larger than life. The card has: a small icon area at top, a labelled name area, a single horizontal flow row with three chips, two small badge tags at the bottom. ${PIP} Pip stands beside the card pointing at each part with a tiny pencil. ${PALETTE}"; }

s4_pattern_support() { gen pattern-support-triage.png "1:1" "Square specimen illustration. White card with a soft sky-blue top bar. ${PIP} Pip sorting a stack of soft envelopes into three labelled trays. Tiny chat bubbles drifting in. ${PALETTE}"; }
s4_pattern_returns() { gen pattern-returns.png "1:1" "Square specimen illustration. White card with a soft sky-blue top bar. ${PIP} Pip stands beside a small cardboard box with a return-arrow symbol, holding a clipboard with checkmarks. ${PALETTE}"; }
s4_pattern_review() { gen pattern-review-responder.png "1:1" "Square specimen illustration. White card with a soft sky-blue top bar. ${PIP} Pip reads a tiny review card with soft stars on it, drafting a reply on a notepad. ${PALETTE}"; }
s4_pattern_daily() { gen pattern-daily-sales.png "1:1" "Square specimen illustration. White card with a soft mint top bar. ${PIP} Pip stands beside a tiny three-bar chart with an up-arrow, holding a small daily briefing card. ${PALETTE}"; }
s4_pattern_inventory() { gen pattern-inventory.png "1:1" "Square specimen illustration. White card with a soft mint top bar. ${PIP} Pip stands in front of a small warehouse shelf with a few boxes, one shelf labelled with a tiny alert dot. ${PALETTE}"; }
s4_pattern_invoice() { gen pattern-invoice-chaser.png "1:1" "Square specimen illustration. White card with a soft mint top bar. ${PIP} Pip drafts on a small envelope with a tiny clock icon nearby (overdue feel). ${PALETTE}"; }
s4_pattern_anomaly() { gen pattern-anomaly.png "1:1" "Square specimen illustration. White card with a soft mint top bar. ${PIP} Pip looks at a small chart with one bar much taller than others, holding up a small magnifier. ${PALETTE}"; }
s4_pattern_adops() { gen pattern-ad-ops.png "1:1" "Square specimen illustration. White card with a soft periwinkle top bar. ${PIP} Pip watches a small dashboard with two ad-platform-style tiles, one tile pulsing soft red. ${PALETTE}"; }
s4_pattern_competitor() { gen pattern-competitor.png "1:1" "Square specimen illustration. White card with a soft periwinkle top bar. ${PIP} Pip with binoculars looking at a faint cluster of small competitor-shop-fronts in the distance. ${PALETTE}"; }
s4_pattern_meeting() { gen pattern-meeting-notes.png "1:1" "Square specimen illustration. White card with a soft cyan top bar. ${PIP} Pip with a small audio-waveform floating in front, turning into a tiny written note card. ${PALETTE}"; }
s4_pattern_compliance() { gen pattern-compliance.png "1:1" "Square specimen illustration. White card with a soft cyan top bar. ${PIP} Pip holds a small document with a soft checkmark stamp and one tiny soft-red flag in the margin. ${PALETTE}"; }
s4_pattern_briefing() { gen pattern-daily-briefing.png "1:1" "Square specimen illustration. White card with a soft rose/peach top bar. ${PIP} Pip with a small coffee mug and a folded briefing card, calm morning feel. ${PALETTE}"; }
s4_sticker() { gen sticker-pattern-spotter.png "1:1" "A circular souvenir sticker / badge on an off-white background. Soft cyan circular ring frame with a small white star at the top. Inside: ${PIP} a tiny Pip with binoculars. Faint dotted ring border. Subtle drop shadow. NO readable text. ${PALETTE}"; }

batch "Station 4 part A" s4_banner s4_legend s4_pattern_support s4_pattern_returns s4_pattern_review s4_pattern_daily
batch "Station 4 part B" s4_pattern_inventory s4_pattern_invoice s4_pattern_anomaly s4_pattern_adops s4_pattern_competitor s4_pattern_meeting
batch "Station 4 part C" s4_pattern_compliance s4_pattern_briefing s4_sticker

# ═══════════════════════════════════════════════════════════════
# STATION 5 — Pick your first one
# ═══════════════════════════════════════════════════════════════

s5_banner() { gen s5-banner.png "16:9" "Wide editorial illustration. A workbench top viewed from a 3/4 angle, four or five small white specimen cards laid out on it. ${PIP} Pip stands behind the bench leaning over with a small magnifying glass, comparing two cards. A tiny lamp throws soft warm light. ${PALETTE}"; }
s5_matrix() { gen s5-matrix.png "1:1" "Square illustration of a 2x2 matrix drawn on a workshop chalkboard or large paper. The top-right quadrant gently glows soft mint with a small soft-yellow star in it. The other three quadrants are softly tinted in pale gray, pale rose, and pale yellow. Faint axis labels (just dashes, unreadable). ${PIP} Pip stands in front of the matrix pointing up at the top-right quadrant. ${PALETTE}"; }
s5_prop_repetitive() { gen s5-prop-repetitive.png "3:4" "Tall portrait. ${PIP} Pip stands beside a small floating loop-arrow icon that repeats in a circle. ${PALETTE}"; }
s5_prop_clean() { gen s5-prop-clean-data.png "3:4" "Tall portrait. ${PIP} Pip holds a neat stack of clean labelled papers in both hands, looking pleased. ${PALETTE}"; }
s5_prop_safe() { gen s5-prop-safe-fail.png "3:4" "Tall portrait. ${PIP} Pip catches a soft falling envelope on a tiny pillow with both hands, gentle smile. ${PALETTE}"; }
s5_prop_measurable() { gen s5-prop-measurable.png "3:4" "Tall portrait. ${PIP} Pip stands beside a small stopwatch with a tiny chart card next to it. ${PALETTE}"; }
s5_q1() { gen s5-q1-frequency.png "1:1" "Small circular illustration. Soft sky-blue circle ring frame. ${PIP} Pip beside a tiny weekly calendar with three or more days circled in soft mint. NO text. ${PALETTE}"; }
s5_q2() { gen s5-q2-sources.png "1:1" "Small circular illustration. Soft mint circle ring frame. ${PIP} Pip pointing at three small labelled boxes representing data sources. NO text. ${PALETTE}"; }
s5_q3() { gen s5-q3-recovery.png "1:1" "Small circular illustration. Soft periwinkle circle ring frame. ${PIP} Pip resetting a small stopwatch beside a stack of envelopes that fell over. NO text. ${PALETTE}"; }
s5_q4() { gen s5-q4-output.png "1:1" "Small circular illustration. Soft cyan circle ring frame. ${PIP} Pip sketching the shape of a message on a piece of paper. NO text. ${PALETTE}"; }
s5_q5() { gen s5-q5-knowing.png "1:1" "Small circular illustration. Soft rose circle ring frame. ${PIP} Pip placing a small mint checkmark on a tiny week-1 calendar. NO text. ${PALETTE}"; }
s5_sticker() { gen sticker-wise-picker.png "1:1" "A circular souvenir sticker / badge on an off-white background. Soft yellow circular ring frame with a small white star at the top. Inside: ${PIP} a tiny Pip with a magnifying glass, looking pleased. Faint dotted ring border. Subtle drop shadow. NO readable text. ${PALETTE}"; }

batch "Station 5 part A" s5_banner s5_matrix s5_prop_repetitive s5_prop_clean s5_prop_safe s5_prop_measurable
batch "Station 5 part B" s5_q1 s5_q2 s5_q3 s5_q4 s5_q5 s5_sticker

# ═══════════════════════════════════════════════════════════════
# STATION 6 — Run it. Don't break it.
# ═══════════════════════════════════════════════════════════════

s6_banner() { gen s6-banner.png "16:9" "Wide editorial illustration. A workshop test bench with a small running agent on it depicted as a soft mint glowing envelope-machine producing tiny envelopes. ${PIP} Pip stands beside it holding a small stopwatch, intently observing. A tiny clipboard hangs from the bench edge. ${PALETTE}"; }
s6_schedule() { gen s6-schedule.png "3:4" "Tall portrait. ${PIP} Pip beside a small wall calendar with 5 weekdays circled in soft mint. ${PALETTE}"; }
s6_trust_ramp() { gen s6-trust-ramp.png "4:3" "Wide editorial illustration of a small ladder with 5 labeled rungs (just dashes for labels, no readable text). ${PIP} Pip stands on the 2nd rung climbing up, smiling. Each rung is tinted progressively from soft yellow at the bottom to soft mint at the top. ${PALETTE}"; }
s6_idk() { gen s6-idk-button.png "3:4" "Tall portrait. ${PIP} Pip holds up a small soft-yellow flag with a question-mark symbol on it. Calm helpful expression. ${PALETTE}"; }
s6_pitfall1() { gen s6-pitfall-1.png "4:3" "Editorial illustration. ${PIP} Pip stands looking up at a comically tall messy tower of objects (representing 'an AI for everything'), about to topple. Soft warm cream warning tint. ${PALETTE}"; }
s6_pitfall2() { gen s6-pitfall-2.png "4:3" "Editorial illustration. ${PIP} Pip surprised, a small soft-yellow paper airplane has flown out without going through a shield (which is on the floor unused beside it). Soft warm cream warning tint. ${PALETTE}"; }
s6_pitfall3() { gen s6-pitfall-3.png "4:3" "Editorial illustration. ${PIP} Pip looking at a blank ruler and an empty graph, slightly puzzled. Soft warm cream warning tint. ${PALETTE}"; }
s6_pitfall4() { gen s6-pitfall-4.png "4:3" "Editorial illustration. ${PIP} Pip holding both hands up trying to catch many soft envelopes flying out too fast. Soft warm cream warning tint. ${PALETTE}"; }
s6_sticker() { gen sticker-operator.png "1:1" "A circular souvenir sticker / badge on an off-white background. Soft warm-cream circular ring frame with a small white star at the top. Inside: ${PIP} a tiny Pip with a stopwatch in one hand. Faint dotted ring border. Subtle drop shadow. NO readable text. ${PALETTE}"; }

batch "Station 6 part A" s6_banner s6_schedule s6_trust_ramp s6_idk s6_pitfall1 s6_pitfall2
batch "Station 6 part B" s6_pitfall3 s6_pitfall4 s6_sticker

# ═══════════════════════════════════════════════════════════════
# STUDIO 7 — The Spec Bench
# ═══════════════════════════════════════════════════════════════

s7_banner() { gen s7-banner.png "16:9" "Wide editorial illustration. ${PIP} Pip stands at a wide spec bench covered in clipboards, sketch papers, pencils, and small drafting tools. One large empty clipboard is propped up in the foreground. Pip gestures 'come over' with one hand. Soft natural light from a window. ${PALETTE}"; }
s7_worked() { gen s7-worked-example.png "4:3" "Editorial illustration of a finished filled-in spec document on a bench, with 14 short rows lightly visible (use abstract dashes, no readable text). A small soft-mint approved stamp in one corner. ${PIP} Pip stands beside it pointing with quiet pride. ${PALETTE}"; }
s7_sticker() { gen sticker-spec-author.png "1:1" "A LARGER circular souvenir sticker / badge on an off-white background. Soft mint circular ring frame with a small white star at the top, plus a faint dotted DOUBLE ring border (this is the prestigious sticker). Inside: ${PIP} Pip holds a finished scroll/document with both hands, smiling with quiet pride. Subtle drop shadow. NO readable text. ${PALETTE}"; }

# Studio 7 field icons (14 small circular illustrations)
s7_f01() { gen s7-f01-name.png "1:1" "Small circular illustration. Soft sky-blue ring. ${PIP} holding a small blank name tag. NO text. ${PALETTE}"; }
s7_f02() { gen s7-f02-job.png "1:1" "Small circular illustration. Soft mint ring. ${PIP} writing one short line on a small piece of paper with a pencil. NO text. ${PALETTE}"; }
s7_f03() { gen s7-f03-problem.png "1:1" "Small circular illustration. Soft rose ring. ${PIP} holding a magnifying glass over a small soft-red pain-point dot. NO text. ${PALETTE}"; }
s7_f04() { gen s7-f04-success.png "1:1" "Small circular illustration. Soft mint ring. ${PIP} beside a tiny three-bar chart with one bar gently highlighted. NO text. ${PALETTE}"; }
s7_f05() { gen s7-f05-trigger.png "1:1" "Small circular illustration. Soft yellow ring. ${PIP} holding a small wall clock. NO text. ${PALETTE}"; }
s7_f06() { gen s7-f06-read.png "1:1" "Small circular illustration. Soft mint ring. ${PIP} with a magnifier hovering over a small neat stack of papers. NO text. ${PALETTE}"; }
s7_f07() { gen s7-f07-context.png "1:1" "Small circular illustration. Soft periwinkle ring. ${PIP} surrounded by 5 small floating note-slips arranged in a fan. NO text. ${PALETTE}"; }
s7_f08() { gen s7-f08-refuse.png "1:1" "Small circular illustration. Soft cyan ring. ${PIP} holding up a small mint shield in a stop gesture. NO text. ${PALETTE}"; }
s7_f09() { gen s7-f09-idk.png "1:1" "Small circular illustration. Soft yellow ring. ${PIP} holding up a tiny soft-yellow flag with a question-mark symbol. NO text. ${PALETTE}"; }
s7_f10() { gen s7-f10-rules.png "1:1" "Small circular illustration. Soft periwinkle ring. ${PIP} reading a small list with three short dashes (no readable text). ${PALETTE}"; }
s7_f11() { gen s7-f11-format.png "1:1" "Small circular illustration. Soft rose ring. ${PIP} sketching the shape of a message on a small paper with a pencil. NO text. ${PALETTE}"; }
s7_f12() { gen s7-f12-post.png "1:1" "Small circular illustration. Soft sky-blue ring. ${PIP} releasing a small soft-yellow paper airplane. NO text. ${PALETTE}"; }
s7_f13() { gen s7-f13-owner.png "1:1" "Small circular illustration. Soft mint ring. ${PIP} holding a small blank ID-badge with one hand. NO text. ${PALETTE}"; }
s7_f14() { gen s7-f14-retire.png "1:1" "Small circular illustration. Soft warm-cream ring. ${PIP} looking at a tiny hourglass running out. NO text. ${PALETTE}"; }

batch "Studio 7 part A" s7_banner s7_worked s7_sticker s7_f01 s7_f02 s7_f03
batch "Studio 7 part B" s7_f04 s7_f05 s7_f06 s7_f07 s7_f08 s7_f09
batch "Studio 7 part C" s7_f10 s7_f11 s7_f12 s7_f13 s7_f14

# ═══════════════════════════════════════════════════════════════
# STUDIO 8 — The Instruction Desk
# ═══════════════════════════════════════════════════════════════

s8_banner() { gen s8-banner.png "16:9" "Wide editorial illustration. ${PIP} Pip sits at an old-fashioned writing desk with an inkwell, a quill pencil, and a small lamp. A neat blank page lies in front. Pip looks thoughtful, pencil to chin. Books and small reference cards line a shelf behind. ${PALETTE}"; }
s8_persona() { gen s8-persona.png "3:4" "Tall portrait. ${PIP} Pip stands beside a small reflection of itself drawn on a mirror, both looking the same, smiling. ${PALETTE}"; }
s8_rules() { gen s8-hard-rules.png "3:4" "Tall portrait. ${PIP} Pip holds up a small chiseled stone tablet (soft gray) with three carved lines on it (no readable text). ${PALETTE}"; }
s8_examples() { gen s8-examples.png "3:4" "Tall portrait. ${PIP} Pip arranges three small specimen cards on a tabletop, each labelled with a tiny numeral. ${PALETTE}"; }
s8_unsure() { gen s8-when-unsure.png "3:4" "Tall portrait. ${PIP} Pip stands at a small fork in a path on the floor, holding up a small question-mark flag, looking thoughtful. ${PALETTE}"; }
s8_compare() { gen s8-compare.png "16:9" "Wide editorial illustration showing two writing pads side by side, separated by a thin vertical dotted line. Left pad: messy scribbled lines, eraser shavings (vague writing). Right pad: neat clear lines, a small pencil at rest (clear writing). ${PIP} Pip stands between them, gesturing approvingly at the right pad. ${PALETTE}"; }
s8_sticker() { gen sticker-voice-coach.png "1:1" "A circular souvenir sticker / badge on an off-white background. Soft periwinkle circular ring frame with a small white star at the top. Inside: ${PIP} a tiny Pip holding a small speech-bubble icon. Faint dotted ring border. Subtle drop shadow. NO readable text. ${PALETTE}"; }

batch "Studio 8" s8_banner s8_persona s8_rules s8_examples s8_unsure s8_compare s8_sticker

# ═══════════════════════════════════════════════════════════════
# STUDIO 9 — The Final Test Bench
# ═══════════════════════════════════════════════════════════════

s9_banner() { gen s9-banner.png "16:9" "Wide editorial illustration. ${PIP} Pip at a final test bench with five small sample input cards on the left, an arrow pointing right to five sample output cards on the right. A small soft-mint approved stamp hovering above one input-output pair. ${PALETTE}"; }
s9_golden() { gen s9-golden.png "3:4" "Tall portrait. ${PIP} Pip holds three small gold-trimmed cards with soft yellow stars on each. ${PALETTE}"; }
s9_evil() { gen s9-evil-twin.png "3:4" "Tall portrait. ${PIP} Pip carefully presents a small broken / torn version of an input card, curious expression. ${PALETTE}"; }
s9_dryrun() { gen s9-dry-run.png "3:4" "Tall portrait. ${PIP} Pip releases a small paper airplane that gently lands on a sandbox tray on the floor instead of flying away. ${PALETTE}"; }
s9_firstweek() { gen s9-first-week.png "3:4" "Tall portrait. ${PIP} Pip with a small daily checklist, marking off 5 boxes with a soft mint check. ${PALETTE}"; }
s9_closing() { gen s9-closing.png "16:9" "Wide editorial illustration. ${PIP} Pip stands at the workshop's open back door, gesturing the viewer out into a soft sunrise. A small completed-clipboard rests against the doorframe. A gentle sense of 'you're ready'. ${PALETTE}"; }
s9_sticker() { gen sticker-agent-builder.png "1:1" "A circular FINAL souvenir sticker / badge on an off-white background. Soft golden-yellow circular ring frame with a small white star at the top, plus a DOUBLE dotted ring border with small dots around (this is the grandest sticker). Inside: ${PIP} Pip smiling warmly, both arms raised in quiet triumph. Subtle drop shadow with a faint sparkle. NO readable text. ${PALETTE}"; }
s9_board() { gen s9-sticker-board.png "4:3" "Editorial illustration of a small wooden souvenir board mounted on a workshop wall, with all 9 circular stickers arranged in a 3x3 grid on it, each in its assigned soft pastel color. ${PIP} Pip stands beside the board admiring it, hands behind back. ${PALETTE}"; }

batch "Studio 9" s9_banner s9_golden s9_evil s9_dryrun s9_firstweek s9_closing s9_sticker s9_board

echo "═══ ALL DONE ═══"
ls -la *.png | wc -l
