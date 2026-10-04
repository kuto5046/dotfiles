# Visual Patterns for HTML Documents

Use these patterns to translate semantic structure into visual structure.

## Executive summary

Use 3–5 concise blocks containing:

- conclusion
- evidence
- implication

Do not merely repeat the section headings.

## Concept map

Use when multiple concepts have explicit relationships.

Structure:

```text
Main concept
  ├─ dimension A
  │   ├─ detail
  │   └─ detail
  └─ dimension B
```

Render with CSS grid/flex and connecting rules, or inline SVG for richer graphs.

## Process flow

Use for ordered execution.

```text
Input → Transform → Validate → Output
```

Each step should answer:

- what happens
- what enters
- what leaves
- what can fail

## Architecture diagram

Separate architectural layers visually:

```text
User / External system
        ↓
Interaction layer
        ↓
Domain / orchestration layer
        ↓
Tools / data / infrastructure
```

Use clear boundaries and arrow labels where the relationship is not obvious.

## Comparison

For 2–4 alternatives, prefer a side-by-side grid.
For more alternatives or many dimensions, prefer a table.

Useful dimensions:

- purpose
- abstraction level
- strengths
- limitations
- operational model
- dependencies
- best-fit scenarios

Avoid declaring a universal winner unless the content supports one.

## Timeline

Use when chronology matters.

Each event should include:

- date / phase
- event
- significance

Horizontal timelines are useful only for small numbers of events. Otherwise prefer vertical.

## Layered explanation

Useful for complex systems.

Pattern:

1. one-sentence intuition
2. visual model
3. component explanation
4. concrete example
5. edge cases / limitations

## Before / After

Use a symmetric two-column layout.

Keep comparison dimensions aligned so differences are immediately visible.

## Decision tree

Use only when branches represent real decision criteria.

Each branch label should be a testable question, not vague wording.

## Metric strip

Use for a small number of critical numbers.

Example:

```text
Latency      420ms
Accuracy     91.4%
Cost/run     $0.08
```

Keep metrics secondary to the document unless quantitative comparison is the central purpose.

## Callout hierarchy

Use visually distinct callout types:

- Insight — interpretation worth remembering
- Note — contextual detail
- Warning — failure mode or risk
- Definition — precise meaning of a term

Avoid more than roughly one callout per major section unless necessary.

## Code + explanation

For short code:

```text
[ explanation ]
[ code block   ]
```

For line-specific explanation, use a two-column layout only if it remains readable. Otherwise annotate below the code.

## Research evidence

A useful research section often has:

```text
Claim
  ↓
Evidence / source
  ↓
Interpretation
  ↓
Implication
```

Keep interpretation visually distinct from directly sourced facts.
