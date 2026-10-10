---
name: noto-paper-slides
description: Create clear Japanese research-paper slide decks from a paper, arXiv URL, PDF, or supplied notes using the Noto presentation template and `gpt-image-2.5` (GPT Image 2.5). By default, keep the cover and slide chrome editable while rendering each content region as one calm, research-grade generated visual that may include concise Japanese copy. Respect an explicitly requested slide count; when no count is given, choose a count that fits the source and storyline. Use when Codex should plan, generate, revise, or export Noto-style paper slides; do not use for ordinary non-presentation summaries.
---

# Noto Paper Slides

Create a 16:9 Japanese presentation whose argument is easy to follow when projected. Keep Noto's default palette and deterministic slide chrome, while using one coherent image-generated content canvas per content slide.

## Non-negotiable design split

- Use `assets/noto-template.pptx` as the visual template. Preserve its canvas, title block, divider, takeaway line, margins, and page-number treatment.
- Keep the cover, slide title, takeaway, visible source line, page number, rules, and repeated decoration as native presentation objects.
- On every non-cover slide, render the body/content region as one wide opaque PNG. The image may contain short Japanese explanatory copy, labels, plots, and diagrams, but must not contain slide chrome.
- Use `gpt-image-2.5` for generated content. Do not substitute another model silently.
- Use `assets/noto-style-reference.png` as the first reference image for every generated content canvas. Follow its visual language, not its literal composition.
- Preserve experimental evidence. When a claim depends on an original figure, table, or exact chart, composite the source faithfully or render an exact chart before placing it in the content canvas; never ask the image model to invent or redraw missing measurements.
- The default palette is `canvas #FFFFFF`, `ink #20201D`, `structure #90B5F9`, `signal #524EF6`, and `emphasis #F06449`. Change it only when the user asks.
- If the user explicitly prioritizes fully editable body content, switch to native-content mode and state that choice; otherwise use image-content mode.

## Before authoring

1. Use the installed `Presentations` skill for PowerPoint creation and validation. Read its implementation and finalization guidance before coding.
2. Read [composition system](references/composition-system.md) before planning a new deck or changing its storyline.
3. Read [template map](references/template-map.md) before using or editing the template.
4. Read [image generation](references/image-generation.md) before generating any non-cover content slide.
5. Inspect the complete paper or supplied source. Record the claim, evidence, units, comparison, and limitations needed for every slide. Do not plan from the abstract alone when the paper is available.

## Plan the deck before generating visuals

Make a slide plan with these fields: `purpose`, `reader question`, `title`, `one-sentence takeaway`, `evidence`, `source`, `layout`, and `visual format`.

- Resolve the slide count before writing the plan:
  - When the user specifies a count, produce exactly that many slides. Count the cover unless the user explicitly excludes it.
  - When the user does not specify a count, do not ask for one merely to proceed and do not apply a fixed default. Draft the minimum complete storyline, giving one slide to each distinct audience question or evidence unit; merge light adjacent points and split any slide that needs two claims, an unreadably dense visual, or more than one major experiment.
  - A single research paper often lands around 8–14 slides including the cover, but treat that only as a sanity check. Short notes may need fewer and complex papers may need more.
- Give each slide one reader question and one answer. Split slides that need two answers.
- Use a plain topic title for setup, definitions, and method overviews. Use a factual takeaway title only when the evidence supports it.
- Write the takeaway below the header as the slide's main claim in one short, plain Japanese sentence, not an agenda or description of the diagram. Keep it on one line at the template's 28 px font size; shorten the wording before shrinking. See the concrete copy examples in the composition system.
- Make mechanism diagrams concrete: identify the actual input, operation, and output, with meaningful stage labels and a small source-grounded example when useful. Specify these in the plan before generating; do not leave the model to fill unnamed boxes.
- Vary density intentionally: follow a dense evidence slide with a simpler synthesis or mechanism slide when the material allows it.
- Do not force the paper into a fixed outline. Allocate slides according to the paper's actual contribution while honoring an explicit count exactly.
- Across the deck, cover enough context to understand the problem, enough method detail to understand what changed, and enough evidence to judge the result. Include limitations when they materially affect the conclusion.

## Choose the evidence source deliberately

Use the smallest reliable visual source for the claim:

| Need | Preferred content-canvas treatment |
| --- | --- |
| Reported result or ablation | Exact chart rendered from paper values, or the original paper figure, embedded faithfully in the canvas |
| Model architecture or pipeline already shown well | Original paper figure with no generative redrawing; add at most two restrained callouts |
| New explanation of a mechanism | `gpt-image-2.5` structural schematic |
| Contrast between two conditions | Shared-axis comparison or original evidence, not two decorative cards |
| Definitions, setup, or limitations | One quiet content canvas with short text fragments and a restrained diagram |
| Qualitative samples | Original examples with concise text inside the content canvas |

Do not turn exact evidence into a plausible-looking synthetic chart. Generation controls composition and annotation; the paper controls values and evidence.

## Build with the template

- Import `assets/noto-template.pptx`; inspect its dimensions, named shapes, and five reference slides.
- Duplicate the matching reference slide rather than painting a new theme over a blank slide.
- Replace every `{{...}}` sample token and remove every shape whose name begins with `REMOVE-ME-`.
- Use reference slide 1 for the cover. For content slides, preserve the template header and footer, remove sample body objects, and place one content PNG in the body region with consistent margins.
- Default body image geometry for the 13.333 × 7.5 in template: approximately `left 80 pt, top 182 pt, width 1120 pt, height 421 pt`. Preserve aspect ratio and leave the source line/footer unobstructed.
- Put citations in speaker notes. Keep a short visible source line only when the audience needs it to interpret the evidence.
- Keep all content-region copy inside the PNG. Do not duplicate the same body copy as native text.

## Generate the content canvas

When a slide needs GPT Image 2.5, follow [image generation](references/image-generation.md). The essential constraints are:

- Model: `gpt-image-2.5` through the installed `imagegen` skill's built-in image generation path.
- Default output: a high-quality wide landscape PNG, about 2.6:1, sized for the template's content region.
- Prompt for one semantic composition, not a complete slide. Always pass `assets/noto-style-reference.png` as the style reference.
- Exclude title bars, subtitles, page numbers, borders, cards, badges, buttons, legends without data, logos, watermarks, and decorative icons.
- Include only the exact Japanese text supplied in the prompt. Prefer short labels and one-line conclusions; keep prose to at most three or four blocks of one or two lines each.
- State every required label and number explicitly. Tell the model not to add any other words or numbers.
- Change the visual grammar from slide to slide only when the content changes. Do not repeat a generic three-box pipeline or evenly spaced rounded-card grid.

## Review gate

Render every slide and review both the deck sequence and each full-size slide.

- The main point must be identifiable within three seconds.
- The evidence path must be followable without scanning back and forth across repeated panels.
- The takeaway must answer the reader question directly. For mechanism diagrams, viewers must be able to say what enters, what happens, and what comes out from the visual alone; regenerate anonymous boxes or unexplained arrows.
- Titles, takeaways, axes, labels, and body text must remain readable at presentation size.
- Compare every generated word, number, model name, unit, category, and range against the slide plan. Regenerate a slide when any item is omitted, merged, misspelled, or paired with the wrong value.
- Original paper figures must preserve their aspect ratio, labels, and meaning.
- No unsupported number or pseudo-chart may appear in generated imagery.
- No two consecutive slides should use the same composition merely because it is easy to reuse.
- The slide chrome and notes must remain editable; the content region is intentionally rasterized in image-content mode. Export slide PNGs as an additional deliverable only when requested.

If the deck feels visually busy, first remove secondary objects, shorten copy, or change the layout. Do not solve clutter by shrinking everything.
