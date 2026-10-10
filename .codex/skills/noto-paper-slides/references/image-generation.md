# GPT Image 2.5 content canvases

Read this before generating any non-cover slide in image-content mode.

## Execution path

Use `gpt-image-2.5` through the installed `imagegen` skill and follow that skill's generation workflow. Do not invent a separate CLI wrapper or silently substitute another model.

- Use `../assets/noto-style-reference.png` as the first reference image. It is the canonical Noto visual-language board.
- Request a high-quality opaque PNG with an aspect ratio around 2.6:1 and generous safe space for the template's body region.
- Generate one asset for each slide's distinct semantic need.
- Inspect every output before placing it, then copy project-bound final assets into the deck workspace.
- Treat the style board as visual-language guidance, not an edit target. Explicitly forbid copying its objects or composition.
- When a paper figure must be preserved, provide it separately and require faithful placement rather than generative redrawing.

## Canonical prompt

Start every prompt with this invariant block, adapted from Noto's own slide generator:

```text
Create one wide presentation content visual in Japanese, aspect ratio about 2.6:1, with a completely opaque white background. It will be placed beneath a native slide header and above a native footer. Include no slide title, subtitle, page number, logo, footer, watermark, or outer border.

The first input image is the shared Noto style board. Do not copy its objects or composition; follow only its visual language: a refined academic research-presentation figure, fine rules, aligned grid, close annotations, precise arrows, disciplined whitespace, and restrained scientific visualization.

Use one dominant focal element and at most three supporting groups. Do not arrange every object with equal size, color, or emphasis. Make the reading path flow in one direction, left-to-right or top-to-bottom. The audience must identify the focus in three seconds and follow its relation to the evidence in the next five seconds.

Palette: background #FFFFFF; text #20201D; structure #90B5F9; main signal #524EF6; decisive emphasis #F06449. Keep signal-colored area and line length below 15%. Use the emphasis color for at most one decisive delta, measurement point, or conclusion.

Use large clean Japanese sans-serif text suitable for projection. Keep lines short and spacing generous. Avoid SaaS cards, pills, buttons, excessive rounding, 3D, gradients, neon, shadows, mascots, decorative icons, generic marketing infographics, and repeated rounded nodes. Do not draw a surrounding panel or container.

For charts, preserve every supplied axis, scale, unit, condition, comparison, and value exactly. Do not invent data, uncertainty, sample sizes, or significance.

For mechanism diagrams, make the process concrete. Identify each input, operation, and output using the supplied labels and example content. Show what changes between representations or states. Never substitute blank rectangles, generic document lines, or an unexplained dot for the information needed to understand the mechanism. Arrows must express the specified transfer, transformation, dependency, or decision.
```

Append the slide-specific block in this order:

```text
PRIMARY CLAIM: <the one relationship the canvas must explain>
EVIDENCE BOUNDARY: <facts and relationships allowed by the source>
VISUAL GRAMMAR: <one archetype from composition-system.md>
CONCRETE MECHANISM: <for mechanism diagrams: actual input, named operations, output, arrow meanings, and the specific content/state change; otherwise omit>
EXAMPLE STATUS: <when using an example: paper example with source, or an illustrative example labeled 「説明用の例」; otherwise omit>
EXACT CONTENT: <all labels, prose fragments, values, model names, and units verbatim>
COMPOSITION: <major regions, focal point, reading path, and relative weight>
CRITICAL CHECKS: <required row count, category-value pairing, scale, or exclusions>
Do not add any other words or numbers.
```

Short explanatory copy is allowed because the content region is intentionally rasterized. Keep it to at most three or four blocks of one or two lines. Prefer a concise conclusion line over paragraphs.

## Format-specific guidance

### Structural schematic

Describe the true input, transformation, state, output, and connection meaning. Put concrete names and useful example content on the diagram, rather than unnamed modules or placeholder lines. When useful, trace one source-grounded input to its output. Give one module more visual weight only when it is the paper's central contribution.

### Mechanism zoom

Use one dominant object and one enlarged internal operation. State what the zoom reveals. Avoid four equal quadrants or decorative insets.

### Transformation

Use a shared spatial frame so the exact change is visible. Place the operation between the two states and make it stronger than the context.

### Shared-axis comparison

Align conditions on the same baseline or scale. Provide every exact value and scale in the prompt, or render the chart deterministically and composite it. Never rely on the model to infer missing values.

### State progression

Use only the stages required by the mechanism. Make size, spacing, or emphasis reflect the actual change rather than repeating identical boxes.

### Failure boundary

Show the successful regime and one explicit boundary or failure mode. Do not dramatize uncertainty with warning icons or red decorative panels.

## Review and retry

Inspect each image at full size and in the rendered slide.

Regenerate with a targeted correction when the image:

- introduces ungrounded data, labels, or components;
- uses a rejected generic pattern;
- leaves stages anonymous or fails to show what changes, so viewers cannot explain the mechanism from the visual;
- makes all elements equally prominent;
- contains unreadable or misspelled text;
- drops a required row, merges categories, or pairs a value with the wrong label;
- requires the audience to scan back and forth;
- includes slide chrome that belongs in the template.

For text or number errors, restate the exact content and critical row/value constraints. If the second attempt still fails, render the exact text or chart deterministically into the raster canvas or use the original evidence. Do not ship a plausible-looking incorrect image.
