---
name: latex-paper
description: Write and format academic LaTeX papers following IEEE TIT/TSP standards, with proper mathematical typesetting, bibliography management, figure/table creation, and venue-specific templates.
---

## What I do

- Structure LaTeX papers (sections, equations, theorems, proofs, algorithms)
- Write clean mathematical notation consistently throughout a document
- Create publication-quality figures with TikZ and pgfplots
- Manage bibliography with biblatex or bibtex
- Format for specific venues (IEEEtran, acmart, Springer svjour3, Elsevier elsarticle)
- Handle cross-references, multi-column equations, subfigures, and tables correctly
- Debug LaTeX compilation errors and warnings
- Write algorithm pseudocode with `algorithm2e` or `algorithmic`

## IEEE TIT/TSP Writing Standards

- Writing tone: objective, neutral, rigorous. No hype words (avoid: groundbreaking, revolutionary, novel, remarkable). Prefer precise, understated academic language.
- Logic: every claim must be supported by derivation, citation, or experiment. No unsupported assertions.
- Style: follow IEEE Transactions conventions. Readers are experts; write for clarity and efficiency, not spectacle.
- Preference aligns with IEEE TSP/TIT editorial taste.

## Math Typesetting Rules

### Inline vs Display Math
- Prefer `\(` `\)` for inline math, NOT `$` `$`
- Prefer `\[` `\]` for unnumbered display math, NOT `$$` `$$`
- All display math in the body should use numbered environments: `equation` (single line) or `align` (multi-line). Avoid unnumbered display equations in the main text unless truly decorative.

### Cross-References
- Use `\Cref{}` from `cleveref` for all cross-references (auto-generates "Fig.", "Eq.", "Theorem", etc.)
- Use `\eqref{}` specifically for equation references when you want "(1)" style
- Never use bare `\ref{}` for equations

### Symbol Macros (from preamble/letterfonts.tex)
When the project uses `preamble/letterfonts.tex`, use these macros:

**Number sets** (with optional dimension superscript):
- `\RR[n]` for R^n, `\CC[n]` for C^n, `\NN`, `\ZZ`, `\QQ`, `\PP`, `\HH`, `\FF`

**Expected value**: `\EE`

**Blackboard bold**: `\bbA` through `\bbZ`
**Bold symbol (mathbf)**: `\bfA` through `\bfZ`, `\bfa` through `\bfz`
**Mathcal**: `\mcA` through `\mcZ`
**Bold symbol (boldsymbol)**: `\bmA` through `\bmZ`, `\bma` through `\bmz`
**Script**: `\sA` through `\sZ`
**Fraktur**: `\mfA` through `\mfZ`, `\mfa` through `\mfz`

**Special operators** (from preamble/macros.tex):
- `\norm{x}` or `\norm*{x}` (auto-sizing) for norms
- `\inorm` for infinity norm
- `\del{f}{x}` for partial derivatives
- `\der{f}{x}` for ordinary derivatives
- `\bs{...}` for bold symbols shorthand
- `\iid` for i.i.d.
- `\eps` for epsilon, `\veps` for varepsilon
- `\rmd` for differential d, `\rme` for constant e
- `\tr` for trace, `\supp` for support

**Other** (from preamble/preamble.tex):
- `\red{...}`, `\blue{...}`, `\green{...}` for colored text
- `\boxedeq{label}{equation}` for boxed highlight equations

## Style Conventions

- Use semantic macros consistently; never hardcode `\mathbb{R}` when `\RR` is available
- Equations: `align` for multi-line, `equation` for single-line
- Figures: always `\centering`, captions below figures, labels above
- Tables: use `booktabs` (`\toprule`, `\midrule`, `\bottomrule`), never `\hline`
- Citations: `\cite{}` with proper bib entries
- Theorems: `\newtheorem` environments, `\label` immediately after `\begin{theorem}`
- Document structure: use `\input{}` to split sections into separate files

## Common Pitfalls

- Not escaping `%`, `&`, `_`, `#` in text mode
- Missing `\\` at end of table rows
- Using `hline` instead of `booktabs` commands
- Forgetting `\usepackage` for special symbols or environments
- Broken cross-references from mismatched `\label`/`\ref`
- Using `\ref{}` instead of `\Cref{}` or `\eqref{}`

## When to use me

Use this skill when writing or editing LaTeX papers, adding equations, creating figures/tables, fixing compilation errors, or formatting for a specific venue.

Ask clarifying questions if:
- The target venue/template is unspecified
- The bibliography style requirement is unclear (numbered vs author-year)
- The paper language is unspecified (English vs Chinese vs bilingual)
- The project does not use the standard preamble macros
