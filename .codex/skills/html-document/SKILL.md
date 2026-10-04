---
name: html-document
description: Create polished, self-contained HTML documents for technical explanations, research reports, architecture notes, specs, comparisons, and visual summaries. Use when the user wants a readable document artifact in HTML rather than a web app or UI mock.
---

# HTML Document

Create a **document that happens to be HTML**, not a web application.

The goal is to turn dense technical content into a visual, readable, shareable artifact that is easier to scan than long Markdown while preserving depth and precision.

## Use this skill when

Use this skill for outputs such as:

- technical reports
- research summaries
- architecture / system design notes
- paper explanations
- product or technology comparisons
- investigation results
- implementation guides
- experiment reports
- decision memos
- concept explainers
- visual documentation

Do **not** use this skill primarily for:

- product UI mockups
- dashboards meant to behave like applications
- interactive SaaS prototypes
- landing pages
- marketing sites
- complex stateful React apps

For those, use a frontend/UI-oriented workflow instead.

## Core principle

Treat HTML as a rich document medium.

Do not simply convert Markdown headings and paragraphs into `<h2>` and `<p>` tags. Re-encode the information according to its semantic structure.

Examples:

- relationships → diagram
- process → flow / timeline
- alternatives → comparison grid or table
- taxonomy → grouped cards
- hierarchy → nested visual structure
- key claim → callout
- quantitative difference → compact metric block
- implementation sequence → numbered stages
- architecture → boxes + arrows

A good document should be understandable through scanning before reading every paragraph.

## Default output constraints

Unless the user asks otherwise:

1. Produce a **single self-contained `.html` file**.
2. Use semantic HTML, CSS, and minimal vanilla JavaScript only when it materially improves navigation or comprehension.
3. Avoid build steps, npm dependencies, React, Tailwind, shadcn, or frameworks.
4. Prefer inline CSS in a `<style>` block.
5. Avoid external assets when possible. If icons are useful, prefer inline SVG.
6. Make the document usable by opening the file directly in a browser.
7. Make it print-friendly.
8. Support narrow screens reasonably, even though desktop reading is the default.

## Workflow

### 1. Determine the document's reading job

Before writing HTML, identify:

- audience
- primary question the document answers
- expected reading mode: scan, study, compare, decide, implement
- information hierarchy
- 3–7 most important takeaways

Do this internally unless clarification is essential.

### 2. Design the information architecture

Choose a document structure appropriate to the content. Typical order:

- title / context
- executive summary or "at a glance"
- conceptual overview
- detailed sections
- diagrams / comparisons
- implementation or implications
- references / notes

Do not force this structure when another structure better matches the material.

### 3. Select visual encodings

For each important section, ask whether prose is the clearest representation.

Prefer visual structures when they reduce cognitive load.

Use the patterns in `references/patterns.md`.

### 4. Establish a restrained visual system

Use a coherent visual language throughout the document.

Default characteristics:

- editorial / technical rather than app-like
- light neutral page background
- readable content width
- strong typography hierarchy
- subtle borders and surfaces
- one main accent color plus semantic colors when needed
- generous whitespace between conceptual groups
- compact spacing inside related groups
- low visual noise

Avoid the stereotypical AI-generated aesthetic:

- excessive gradients
- purple/blue neon glow
- glassmorphism without a semantic reason
- every section inside a rounded card
- oversized hero sections
- decorative blobs
- excessive icons
- random color variation

### 5. Write the document

The document should optimize for **progressive disclosure**:

- first glance: structure and conclusions
- second pass: diagrams, comparisons, key details
- deep read: full explanation and caveats

Prefer short paragraphs. Move dense enumerations into tables, labeled blocks, diagrams, or compact lists.

### 6. Verify before finishing

Check:

- Does the HTML open standalone?
- Can the main argument be understood by scanning?
- Are diagrams and tables legible without horizontal scrolling on normal desktop widths?
- Is any information duplicated unnecessarily?
- Are cards being used because they help grouping, not just decoration?
- Are headings meaningful rather than generic labels like "Overview" everywhere?
- Does the visual hierarchy match the semantic hierarchy?
- Is code shown in `<pre><code>` with horizontal overflow handling?
- Are links visibly distinguishable?
- Does print output remain readable?

## Typography

Prioritize readability over novelty.

Default system stack is acceptable for body text. For a more editorial document, use a serif heading stack paired with a sans-serif body stack, but avoid external font dependencies unless explicitly requested.

Recommended defaults:

- body: 15–17px
- line-height: 1.6–1.75
- content width: 960–1180px depending on visual density
- prose width inside wide layouts: 65–80 characters where possible
- section spacing: visibly larger than within-section spacing

Use monospaced typography only for code, identifiers, file paths, commands, and data labels.

## Color

Use CSS variables.

At minimum define:

```css
:root {
  --bg: #f7f7f5;
  --surface: #ffffff;
  --text: #1f2328;
  --muted: #667085;
  --border: #e5e7eb;
  --accent: #3157d5;
  --accent-soft: #eef2ff;
  --success: #16794b;
  --warning: #9a6700;
  --danger: #b42318;
}
```

These are defaults, not mandatory values. Adapt the palette to the subject when appropriate.

Color must communicate meaning, not merely decorate sections.

## Layout

Prefer one of these document shells:

### Reading document

Best for reports and explanations.

- centered content column
- optional narrow summary rail
- full-width diagrams only when needed

### Visual report

Best for comparisons and system explanations.

- 10–12 column CSS grid
- prose spans 6–8 columns
- diagrams may span full width
- small summary blocks can sit side by side

### Reference document

Best for specs and implementation guides.

- sticky or compact table of contents
- clearly separated sections
- anchors for headings
- code / schema / examples optimized for lookup

Do not imitate application navigation unless the document genuinely requires it.

## Diagrams

Prefer native HTML/CSS diagrams for simple structures and inline SVG for complex relationships.

Use diagrams for:

- architectures
- data flows
- execution flows
- state transitions
- dependency relationships
- before/after comparisons

Rules:

- every node must have a clear semantic label
- arrows must convey an explicit relationship
- avoid crossing arrows when possible
- diagrams should remain understandable without relying solely on color
- include a short textual interpretation below complex diagrams

Do not use Mermaid by default because standalone rendering may depend on external JavaScript. Use it only if the user explicitly prefers Mermaid or the environment guarantees rendering.

## Tables

Use tables when comparison across common dimensions matters.

Good uses:

- A vs B
- option tradeoffs
- benchmark results
- feature matrices
- experiment conditions

Avoid giant tables that require excessive horizontal scrolling. Split or reframe them when necessary.

## Cards

Cards are semantic grouping devices, not the default container for every paragraph.

Use cards for:

- parallel alternatives
- grouped concepts
- concise takeaways
- repeated entities with a consistent schema

Avoid nesting cards inside cards.

## Callouts

Use callouts sparingly for:

- important conclusion
- caveat
- implementation warning
- key insight
- definition

A document with too many callouts has no hierarchy.

## Code and technical content

For technical documents:

- preserve exact identifiers
- differentiate commands, file paths, types, and conceptual prose
- use syntax-like spacing even without a syntax highlighter
- annotate only the important lines instead of over-explaining every line
- place code near the explanation it supports

When explaining architecture, show both:

1. the conceptual model
2. the concrete implementation mapping

## Evidence and citations

When the content comes from research:

- keep source links near the claims they support when practical
- add a References section for major sources
- distinguish sourced fact, interpretation, and recommendation
- do not fabricate citations

## Accessibility

At minimum:

- sufficient contrast
- semantic headings in order
- descriptive link text
- `aria-label` for icon-only controls if any
- do not communicate status through color alone
- ensure diagrams have nearby textual interpretation

## Print styles

Include a compact print stylesheet for substantial documents:

```css
@media print {
  body { background: white; }
  .no-print { display: none !important; }
  .section, .card, pre, table { break-inside: avoid; }
  a { color: inherit; text-decoration: none; }
}
```

## Quality bar

The output should feel like a carefully edited technical publication, not a generated webpage.

A strong result has:

- obvious hierarchy
- high information density without clutter
- deliberate visual encoding
- minimal ornamental UI
- diagrams that genuinely clarify
- consistent spacing and typography
- a clear reading path

Before finalizing, remove any visual element that does not improve comprehension.

## Reference files

Read these when relevant:

- `references/patterns.md` — mapping information types to visual patterns
- `references/style-guide.md` — concrete visual defaults and anti-patterns
