# Composition system

Use this reference when planning a deck or changing slide structure. The goal is a sequence of distinct answers, not a gallery of image-model patterns.

## Deck-level narrative

Start from the audience's questions and the paper's evidence. A useful sequence often moves through:

1. What problem matters here?
2. Why do existing approaches fall short?
3. What did the paper change?
4. How does the method work at the level needed to trust it?
5. How was it tested?
6. What changed in the results, under which conditions?
7. Where does the result break or remain uncertain?
8. What should the audience remember?

This is a reasoning order, not a mandatory slide count. Combine or expand stages according to the paper and the user's requested length. If the user gives no count, retain every stage needed for a complete argument, merge only genuinely light adjacent questions, and split overloaded stages until each slide has one claim and one readable evidence path.

## Slide contract

Each slide should answer one reader question using one dominant visual relationship.

- `title`: names the subject or supported finding.
- `takeaway`: the slide's main claim, stated directly in one short, plain Japanese sentence below the header.
- `evidence`: the figure, values, method detail, or quotation that supports the takeaway inside the content canvas.
- `visual path`: focal point, supporting evidence, then implication.

If the title and takeaway say the same thing, rewrite one. If the visual does not support the takeaway, change the visual or the claim.

### Takeaway copy

State what the audience should understand, not what the presenter will explain. Prefer about 25–35 Japanese characters when that preserves the meaning; use one line at 28 px (21 pt). Keep the subject and the concrete result or relationship clear. Avoid agenda wording such as 「〜を説明する」「〜を整理する」, vague benefits, and lists of topics. Retain conditions that change the claim; move secondary detail into the body or notes. Shorten before reducing the font size.

| Weak description | Clear slide claim |
| --- | --- |
| 実行手順の固定とモデルの判断の限界を説明する | 手順を固定しても、モデルの判断ミスは残る |
| ハーネスとモデルの役割を整理する | ハーネスが手順を進め、モデルが意味を判断する |
| 提案手法とベースラインの性能比較 | 評価した条件では、提案手法がベースラインを上回る |

These are wording examples, not claims to reuse without supporting evidence.

### Concrete mechanism diagrams

Use a real object or representation at the input and output, and label each necessary operation with what it does. Arrows should mean a specific transfer, transformation, dependency, or decision. Show the changed content or state where it explains the mechanism; labels alone are insufficient when they remain abstract.

For example, instead of a document icon followed by four blank rectangles and an error dot, follow one short requirement through the diagram: the original requirement, the compiled instruction, the named execution step, the model's decision, and the resulting output. Expose the omitted condition or incorrect decision at the exact point it occurs. Use an example from the paper when available. If an invented example is needed, mark it 「説明用の例」 and do not present it as an observed failure or measurement.

Keep only the stages needed for the claim. A compact before/after example or one decision branch is often clearer than a long pipeline. Do not add code, tools, stages, or implementation details the source does not support. Conceptual overview diagrams may stay schematic, but every displayed object must have an identifiable role.

## Layout and visual grammar

### Noto Visual

Use for one dominant relationship that benefits from a wide canvas: architecture overview, end-to-end pipeline, one large qualitative example, or a single result chart.

- Keep one focal region and at most three supporting groups.
- Use whitespace to separate stages instead of enclosing every stage in a card.
- Use one directional reading path.

### Noto Split

Use when the audience needs short explanatory text beside a mechanism or example.

- Left side: two to four facts, conditions, or decisions rendered inside the content canvas.
- Right side: one self-contained visual relationship.
- Do not use the left side to repeat labels already visible in the image.

### Noto Evidence

Use for a paper figure, table crop, or qualitative examples that must remain visually faithful.

- Give the source evidence the largest area.
- Add no more than two callouts inside the content canvas, placed next to the exact evidence they describe.
- Do not redraw the evidence with an image model.

### Noto Results

Use for an exact chart or table made from reported values and rasterized into the content canvas.

- Preserve axis, unit, condition, baseline, and uncertainty information needed to interpret the result.
- Highlight one decisive comparison. Keep the rest neutral.
- Prefer direct labels to a distant legend when space allows.

### Noto Cover

Keep the cover quiet. Use the paper title, authors or venue when available, and one short framing line. Do not add an image unless it materially identifies the subject.

## Generated-visual archetypes

Choose one only when source evidence or native objects cannot explain the idea better.

- **Structural schematic:** one large system silhouette or spatial structure with a clear entry and exit.
- **Mechanism zoom:** a main object plus one magnified internal operation; avoid multiple equal insets.
- **Transformation:** before and after connected through the exact operation that changes the representation.
- **Shared-axis comparison:** two conditions aligned to the same baseline, scale, or spatial frame.
- **State progression:** a small number of stages whose sizes and emphasis reflect what changes; avoid evenly weighted steps.
- **Failure boundary:** a central successful regime with one clearly marked limit or failure mode.

## Patterns to reject

Reject or regenerate visuals that rely on any of these as the main structure:

- equal rounded cards arranged in a grid;
- generic three-step pipelines with identical boxes and arrows;
- dashboard panels, tabs, badges, pills, or fake controls;
- a central glowing object surrounded by generic icons;
- repeated circles connected by decorative lines;
- text-heavy infographics that duplicate the native title or takeaway;
- stock-photo metaphors for technical claims;
- gradients, neon, glass effects, or depth used without semantic meaning;
- diagrams in which every object has the same color, scale, and emphasis.

## Rhythm across the deck

- Do not repeat a layout on adjacent slides unless they form a true pair, such as two comparable experiments.
- Repeat visual encodings only when their meaning repeats. For example, use `signal` for the proposed method path and `emphasis` for the decisive delta throughout the deck.
- Keep dense slides rare and purposeful. A slide with detailed evidence should be followed by a slide that synthesizes or explains it when the narrative supports that move.
- Every content slide uses a body canvas, but it need not be illustration-heavy. Setup and limitation slides may use a quiet text-led canvas with substantial empty space.

## Copy limits

- Cover title: prefer 40–60 pt depending on length.
- Slide title: 32–40 pt.
- Takeaway: default 28 px (21 pt) on the 1280 × 720 template; keep one line and shorten before shrinking.
- Body: 18–24 pt.
- Visible source: 11–14 pt.
- Body copy: usually two to four points; shorten before shrinking.
- In-image labels: large, exact, and sparse. Short prose is allowed, but keep it to three or four compact blocks and never duplicate the native title or takeaway.
