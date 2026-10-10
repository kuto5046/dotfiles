# Noto template map

Use `../assets/noto-template.pptx` as the starting deck. It uses a 16:9, 1280 × 720 canvas and keeps Noto's existing default colors.

## Theme tokens

| Role | Value | Use |
| --- | --- | --- |
| Canvas | `#FFFFFF` | Slide background |
| Ink | `#20201D` | Titles, body, axes, ordinary labels |
| Structure | `#90B5F9` | Divider and secondary structure |
| Signal | `#524EF6` | Active method path or pivotal module |
| Emphasis | `#F06449` | One decisive result or conclusion |

## Reference slides

Duplicate a reference slide, move the duplicate into the desired order, then replace its header/footer text and body guide. Delete the five original reference slides before delivery. In image-content mode, the chosen reference affects the available footer/source treatment, but the sample body layout is removed and replaced by one wide content PNG.

### Noto Cover

Reference slide 1. Fill `noto-cover-title`, `noto-cover-subtitle`, and `noto-cover-meta`. Keep it minimal.

### Noto Visual

Reference slide 2. Default for content slides without a visible source line. Fill `noto-title`, `noto-takeaway`, and `noto-page`. Remove `REMOVE-ME-visual-guide` and place the wide content PNG in the body region.

### Noto Split

Reference slide 3. Use only when native-content mode is explicitly requested. In image-content mode, do not keep `noto-body`; put the explanatory copy and visual relationship together in the body PNG.

### Noto Evidence

Reference slide 4. Use when a visible source line is useful. Fill `noto-title`, `noto-takeaway`, `noto-source`, and `noto-page`. Remove `noto-callout` and `REMOVE-ME-evidence-guide`; place the source figure and any short callouts inside the body PNG.

### Noto Results

Reference slide 5. Use when a visible source line is useful for a result. Fill `noto-title`, `noto-takeaway`, `noto-source`, and `noto-page`. Remove `noto-result-note` and `REMOVE-ME-results-guide`; place the exact chart or table inside the body PNG.

## Image-content body region

- Use one opaque wide PNG per non-cover slide.
- Default placement on the 1280 × 720 canvas: `left 80`, `top 182`, `width 1120`, `height 421` points.
- Preserve the PNG aspect ratio and keep its bottom above visible source lines around `top 625` and the page number around `top 672`.
- Delete all other body shapes, images, and charts. Keep only the title bar, divider, title, takeaway, source line when needed, and page number.

## Template invariants

- `noto-takeaway`: 28 px (21 pt), in the existing `left 110, top 122, width 1040, height 44` box on the 1280 × 720 canvas. Use a concise one-line claim; do not compensate for long copy by shrinking it.
- Do not move the title bar, divider, title, takeaway, or page number unless the user asks for a redesign.
- Do not rasterize the cover, title, takeaway, source line, page number, rules, or repeated decoration.
- Remove all sample tokens such as `{{TITLE}}` and all `REMOVE-ME-*` guide shapes before delivery.
- Use the same page-number position throughout the deck.
- Keep visual content within the intended region; contain evidence rather than cropping away labels or axes.
- Treat `signal` and `emphasis` as semantic colors, not decoration. The emphasis color should normally appear at most once per slide.

The template can be regenerated with `scripts/build_template.mjs` when its layouts change. Deck-generation tasks should import the PPTX asset directly rather than rebuilding it.
