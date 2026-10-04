# HTML Document Style Guide

## Desired feel

Editorial technical document: calm, precise, information-dense, and deliberately designed.

Think:

- research report
- engineering design doc
- technical magazine
- high-quality internal memo

Not:

- SaaS dashboard
- landing page
- component gallery
- marketing hero page

## Page shell

Recommended starting point:

```css
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  line-height: 1.65;
}
main {
  width: min(1120px, calc(100% - 40px));
  margin: 0 auto;
  padding: 64px 0 96px;
}
```

## Surfaces

Use white surfaces sparingly against a slightly tinted page background.

Prefer:

```css
.panel {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
}
```

Avoid making every section a panel.

## Shadows

Prefer borders to shadows.

If a shadow is useful, keep it subtle:

```css
box-shadow: 0 8px 24px rgba(16,24,40,.06);
```

## Headings

Headings should communicate information hierarchy, not merely increase font size.

Suggested scale:

- h1: 36–46px
- h2: 25–30px
- h3: 18–21px
- body: 15–17px
- metadata: 12–14px

## Spacing

Use larger gaps between concepts than within concepts.

Typical rhythm:

- major sections: 64–88px
- subsection groups: 32–48px
- paragraph spacing: 12–18px
- compact card padding: 18–24px

## Borders

Prefer thin, low-contrast borders.

Strong borders should communicate grouping or status.

## Radius

Use restrained radius:

- small: 6–8px
- panel: 10–14px

Avoid pill-shaped containers except for tags/status labels.

## Tags

Tags are useful for metadata such as:

- Experimental
- Recommended
- Deprecated
- Source
- Input / Output

Do not use decorative tags for every heading.

## Diagram nodes

Diagram nodes should use a consistent grammar:

- title
- optional secondary label
- optional concise description

Use different styling for different semantic node types, not random variation.

## Table styling

Recommended:

- sticky header only for long tables
- subtle row separators
- left aligned text
- tabular numerals for metrics
- avoid vertical rules unless needed

## Navigation

A table of contents is useful for long documents.

Keep it document-like:

- anchor links
- compact section list
- optional sticky position on desktop

Avoid app-style side navigation unless the document is genuinely reference-heavy.

## Interaction

Interaction should support reading, not transform the artifact into an application.

Good interactions:

- collapse long details
- copy code button
- anchor navigation
- small tabs for alternate representations

Avoid:

- modal-heavy UX
- arbitrary hover animations
- draggable panels
- fake settings controls

## Animation

Default: none.

Use subtle transitions only for user-triggered disclosure.

## Dark mode

Do not add dark mode unless requested or clearly valuable. A single excellent visual theme is preferable to two mediocre themes.

## Responsive behavior

On narrower screens:

- multi-column grids collapse to one column
- wide diagrams allow horizontal scroll only as a last resort
- typography scales down modestly
- side TOC becomes non-sticky or hidden

## Anti-patterns

Avoid:

- generic gradient hero banners
- large empty hero area before useful content
- excessive rounded cards
- 3-column layouts for long prose
- giant emoji icons
- fake browser chrome
- gratuitous glassmorphism
- repetitive "Key Takeaway" boxes
- unexplained color coding
- decorative charts with no analytical purpose
- prose copied verbatim into cards

## Final editing pass

Ask:

1. What can be removed?
2. What prose should become a visual?
3. What visual should become simpler prose?
4. Which sections are visually over-emphasized relative to importance?
5. Can a reader identify the conclusion in under 20 seconds?
