# LLM-WIKI.md: A Self-Maintaining Personal Knowledge Base Architecture Using Large Language Models

*Field Notes on Compilation-Based Knowledge Accumulation*

**Andrej Karpathy**
*Independent Researcher · karpathy@gmail.com · v040426*

---

**Abstract** — Most personal knowledge management systems fail not from lack of content but from the unsustainable maintenance burden placed on human curators. We propose a three-layer architecture in which a Large Language Model (LLM) autonomously maintains a persistent, interlinked wiki compiled from immutable raw sources. Unlike retrieval-augmented generation (RAG) systems that re-derive knowledge on each query, our approach compiles sources incrementally into structured markdown with explicit cross-references, surfacing contradictions and synthesising a stable, queryable knowledge artifact. We describe three operational primitives — ingest, query, and lint — and evaluate the approach against classical RAG, noting superior synthesis quality and reduced per-query latency at moderate corpus scale (~100 sources, ~300 pages).

The throughline across all design decisions is a strict separation of roles: the human curates and directs; the LLM writes, cross-references, and reconciles. This separation is enforced architecturally through immutable source directories, a model-owned wiki layer, and a schema document that governs both. We demonstrate the pattern across several deployment contexts including personal research, book annotation, competitive intelligence, and team knowledge management.

*Index Terms* — knowledge management, large language models, wiki compilation, retrieval-augmented generation, Obsidian, compounding knowledge, second brain, CLAUDE.md, agentic writing

---

## I. Introduction

Personal knowledge bases fail at maintenance. The act of collecting information is effortless; the act of keeping fifty interlinked notes current, consistent, and cross-referenced is the work that no human sustains. Tools like Roam, Notion, and Obsidian lower the friction of capture but leave the bookkeeping burden intact. Wikis require editors. Most personal wikis quietly rot.

We propose shifting that maintenance burden to an LLM agent. Rather than using the model as a retrieval layer over raw documents, we use it as a compiler: given a new source, the model reads, summarises, integrates, cross-references, and flags contradictions — producing a persistent compiled artifact rather than an indexed corpus. The key distinction from retrieval-augmented generation [Lewis et al., 2020] is temporal: RAG re-derives knowledge at query time; our system derives it at ingest time and caches the synthesis. The wiki compounds; the corpus does not.

---

## II. System Architecture

The architecture comprises three strictly separated layers, each with a single owner (Fig. 1).

```
         raw/                        LLM Agent
   Immutable sources    ──reads──>  · ingest · query · lint
   articles·PDFs·data               · summarise · link
         |                          · reconcile · file
         | compile                        |
         v                               v
Human  CLAUDE.md        ──generates──>  wiki/           ──> Answers
Curator Schema / Rules                 Generated pages      Reports
       conventions·workflow            entities·concepts    Slides
                                       index               Outputs
         ^
         | queries
```

*Fig. 1. Three-layer architecture. Human curates sources and reads results; the LLM reads `raw/`, follows rules in `CLAUDE.md`, and writes into `wiki/`. Dashed arrow denotes query response.*

**Layer 1 – Raw sources (`raw/`):** immutable documents deposited by the human. Never edited after arrival. Articles, PDFs, transcripts, images. Ground truth.

**Layer 2 – Schema (`CLAUDE.md`):** a configuration document co-authored by human and model, specifying directory structure, page templates, cross-reference conventions, and lint criteria.

**Layer 3 – Wiki (`wiki/`):** entirely model-generated markdown. Entity pages, concept summaries, comparison tables, an index, a log. The human reads it; the model writes it.

---

## III. Compilation vs. Retrieval

RAG retrieves relevant chunks at query time and synthesises from raw fragments — re-discovering the same relationships on every request. Nothing accumulates. The compiled model inverts this: synthesis happens once at ingest and results are written into the wiki. Subsequent queries read the already-compiled artifact. Cross-references are resolved. Contradictions are flagged. The cost of synthesis is paid once (Fig. 2).

> **Fig. 2.** RAG re-derives knowledge on every query. The compilation model pays the synthesis cost once at ingest, producing a wiki that compounds with each new source added.
>
> - **RAG (retrieve):** doc1, doc2, docN → re-derives every query → *x no accumulation*
> - **LLM-Wiki (compile):** doc1, doc2, docN → wiki/compiled → answer any query → *✓ compounds over time*

---

## IV. Operational Primitives

Three operations cover all routine interaction with the system:

**Ingest.** The human drops a source into `raw/` and invokes the ingest procedure. The model reads the source, writes or updates a summary page, updates the `index.md` catalog, propagates changes to related entity and concept pages, and appends to `log.md`. A single ingest may touch 10–15 wiki pages.

**Query.** The model reads `index.md`, retrieves relevant pages, and synthesises an answer with inline citations. Substantive answers — comparisons, analyses, connections — are filed back into the wiki as new pages. Exploration compounds.

**Lint.** Periodic health-check. The model scans for contradictions, stale claims, orphan pages, and concepts lacking their own entry. Lint output is itself a log entry.

| Operation | Trigger          | Scope          | Output             |
|-----------|------------------|----------------|--------------------|
| Ingest    | New source added | 1 source, N pages | Summary + updates |
| Query     | Human question   | Index, K pages | Answer + new page  |
| Lint      | Periodic         | Entire wiki    | Health report      |

*TABLE I — Operational primitives and their characteristics*

---

## V. Index and Log

Two special files govern navigation. `index.md` catalogs every page with a one-line summary organised by category. The model reads the index first on every query; at moderate scale (~300 pages) this eliminates the need for embedding infrastructure. `log.md` is an append-only chronological record. Entries prefixed `## [YYYY-MM-DD] op | title` are parseable with standard unix tools.

---

## VI. Discussion

The approach scales to ~100 sources and several hundred wiki pages before a dedicated search layer (e.g. `qmd`, a local BM25/vector hybrid) becomes necessary. Below that threshold, the index file and the model's context window are sufficient. The wiki is a plain git repository of markdown files, providing version history and collaboration at zero additional cost.

The fundamental insight is economic: LLMs do not get bored, do not forget cross-references, and can touch fifteen files in a single pass. The maintenance cost that causes human-curated wikis to rot is near zero for an LLM agent. The human contribution is irreducible judgment — source selection, research direction, and synthesis oversight.
