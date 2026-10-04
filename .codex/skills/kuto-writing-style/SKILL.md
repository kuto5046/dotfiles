---
name: kuto-writing-style
description: Draft or revise Japanese technical articles in Kyohei Uto (kuto)'s evidence-led, approachable style. Use when asked to write in the user's or kuto's style, turn research, experiments, or competition notes into an article, or align an existing draft with that voice. Do not use for generic Japanese writing when no style match is requested.
---

# Kuto Writing Style

Write Japanese technical prose that follows kuto's established explanatory habits without copying sentences from past articles.

Before drafting or revising, read [references/style-guide.md](references/style-guide.md). Use [references/source-index.md](references/source-index.md) only when recalibrating the style, explaining its basis, or updating the corpus.

## Preserve the content boundary

- Transfer voice, information architecture, and reasoning habits—not facts, opinions, experiences, or conclusions from the reference articles.
- Never invent first-hand experience, experimental results, competition participation, personal preferences, or confidence the user has not supplied.
- Distinguish sourced facts, observed results, and personal interpretation. Preserve uncertainty where evidence is limited.
- Follow the user's requested platform, length, audience, and structure. Add Zenn frontmatter only when requested or when producing a ready-to-publish Zenn article.
- Keep citations close to the claims they support. Verify current or externally sourced claims when the task calls for research.

## Drafting workflow

1. Infer the article's purpose and choose the nearest pattern from the style guide: research survey, experiment report, competition retrospective, or troubleshooting/how-to.
2. Establish the reader's context early: motivation, scope, assumptions, and what the article will explain.
3. Move from overview to detail. Define unfamiliar terms before relying on them, then connect mechanisms to concrete evidence, numbers, examples, or results.
4. Use headings and bullets to expose the logic of the article. After a list, add prose that interprets why the items matter when that interpretation is not obvious.
5. Separate three layers explicitly:
   - what a source or result says;
   - what can be observed from it;
   - what the author personally infers or recommends.
6. End with a compact recap and, when natural, a restrained personal reflection or forward-looking sentence.
7. Run the self-check in the style guide and remove unsupported certainty, ornamental prose, repeated conclusions, and excessive imitation tics.

## Default output

Return clean Markdown. If revising a supplied draft, preserve correct technical content and links while changing only what is needed to align the voice and structure. If essential evidence or personal experience is missing, use a clear placeholder or state the limitation instead of fabricating it.
