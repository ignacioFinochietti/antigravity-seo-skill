# Architecture

## Overview

Claude SEO follows Anthropic's official Claude Code skill specification with a modular, multi-skill architecture.

## Directory Structure

The plugin ships 25 sub-skills (21 core + 1 orchestrator + 1 framework integration + 2 extension mirrors) and 18 sub-agents (15 core + 1 framework integration + 2 extension mirrors).

```
~/.claude/plugins/.../antigravity-seo/
â”œâ”€â”€ skills/
â”‚   â”œâ”€â”€ seo/                    # Main orchestrator
â”‚   â”‚   â”œâ”€â”€ SKILL.md
â”‚   â”‚   â””â”€â”€ references/         # On-demand reference files (13 files)
â”‚   â”‚
â”‚   â”œâ”€â”€ seo-audit/              # Full site audit (parallel subagents)
â”‚   â”œâ”€â”€ seo-page/               # Single page analysis
â”‚   â”œâ”€â”€ seo-technical/          # Technical SEO (9 categories)
â”‚   â”œâ”€â”€ seo-content/            # E-E-A-T and content quality
â”‚   â”œâ”€â”€ seo-content-brief/      # Competitive content brief generation
â”‚   â”œâ”€â”€ seo-schema/             # Schema markup detection and generation
â”‚   â”œâ”€â”€ seo-sitemap/            # XML sitemap analysis and generation
â”‚   â”œâ”€â”€ seo-images/             # Image optimization analysis
â”‚   â”œâ”€â”€ seo-geo/                # AI search optimization (GEO)
â”‚   â”œâ”€â”€ seo-local/              # Local SEO (GBP, citations, reviews)
â”‚   â”œâ”€â”€ seo-maps/               # Maps intelligence (geo-grid, GBP audit)
â”‚   â”œâ”€â”€ seo-backlinks/          # Backlink profile analysis
â”‚   â”œâ”€â”€ seo-cluster/            # Semantic topic clustering (SERP-based)
â”‚   â”œâ”€â”€ seo-sxo/                # Search Experience Optimization
â”‚   â”œâ”€â”€ seo-drift/              # SEO drift monitoring (baselines)
â”‚   â”œâ”€â”€ seo-ecommerce/          # E-commerce SEO (product schema, marketplaces)
â”‚   â”œâ”€â”€ seo-hreflang/           # International SEO and hreflang
â”‚   â”œâ”€â”€ seo-plan/               # Strategic SEO planning (industry templates)
â”‚   â”œâ”€â”€ seo-programmatic/       # Programmatic SEO at scale
â”‚   â”œâ”€â”€ seo-competitor-pages/   # Competitor comparison page generation
â”‚   â”œâ”€â”€ seo-google/             # Google SEO APIs (GSC, PSI, CrUX, GA4)
â”‚   â”œâ”€â”€ seo-flow/               # FLOW framework integration (CC BY 4.0)
â”‚   â”œâ”€â”€ seo-dataforseo/         # DataForSEO MCP mirror (extension surface)
â”‚   â””â”€â”€ seo-image-gen/          # Banana MCP mirror (extension surface)
â”‚
â””â”€â”€ agents/
    â”œâ”€â”€ seo-technical.md        # Crawlability, indexability, security
    â”œâ”€â”€ seo-content.md          # E-E-A-T, readability, thin content
    â”œâ”€â”€ seo-schema.md           # Structured data validation
    â”œâ”€â”€ seo-sitemap.md          # Sitemap quality gates
    â”œâ”€â”€ seo-performance.md      # Core Web Vitals
    â”œâ”€â”€ seo-visual.md           # Screenshots, mobile rendering
    â”œâ”€â”€ seo-geo.md              # AI crawler access, citability
    â”œâ”€â”€ seo-local.md            # GBP signals, NAP, reviews
    â”œâ”€â”€ seo-maps.md             # Geo-grid, competitor radius mapping
    â”œâ”€â”€ seo-backlinks.md        # Moz, Bing Webmaster, Common Crawl
    â”œâ”€â”€ seo-cluster.md          # Semantic clustering analysis
    â”œâ”€â”€ seo-sxo.md              # Page-type, user stories, personas
    â”œâ”€â”€ seo-drift.md            # Baseline comparison, regression detection
    â”œâ”€â”€ seo-ecommerce.md        # Product schema, marketplace intelligence
    â”œâ”€â”€ seo-google.md           # GSC, PSI, CrUX, GA4 analyst
    â”œâ”€â”€ seo-flow.md             # FLOW framework prompt selection
    â”œâ”€â”€ seo-dataforseo.md       # DataForSEO MCP mirror
    â””â”€â”€ seo-image-gen.md        # Banana MCP mirror
```

## Component Types

### Skills

Skills are markdown files with YAML frontmatter that define capabilities and instructions.

**SKILL.md Format:**
```yaml
---
name: skill-name
description: >
  When to use this skill. Include activation keywords
  and concrete use cases.
---

# Skill Title

Instructions and documentation...
```

### Subagents

Subagents are specialized workers that can be delegated tasks. They have their own context and tools.

**Agent Format:**
```yaml
---
name: agent-name
description: What this agent does.
tools: Read, Bash, Write, Glob, Grep
---

Instructions for the agent...
```

### Reference Files

Reference files contain static data loaded on-demand to avoid bloating the main skill.

## Orchestration Flow

### Full Audit (`/seo audit`)

```
User request
    â”‚
    â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   seo            â”‚  Main orchestrator (skills/seo/SKILL.md)
â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚  Detects business type and signals
         â”‚  Spawns subagents in parallel
         â”‚
    â”Œâ”€â”€â”€â”€â”´â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”
    â–¼         â–¼        â–¼        â–¼        â–¼        â–¼        â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”
â”‚tech   â”‚ â”‚contentâ”‚ â”‚schema â”‚ â”‚sitemapâ”‚ â”‚perf   â”‚ â”‚visual â”‚ â”‚geo    â”‚
â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”¬â”€â”€â”€â”˜
    â”‚         â”‚         â”‚         â”‚         â”‚         â”‚         â”‚
    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                             â”‚
                             â”‚  Conditional spawns:
                             â”‚  - seo-google     (Google API creds detected)
                             â”‚  - seo-local      (local business detected)
                             â”‚  - seo-maps       (local + DataForSEO MCP)
                             â”‚  - seo-backlinks  (Moz/Bing/CC available)
                             â”‚  - seo-cluster    (content strategy signals)
                             â”‚  - seo-sxo        (always in full audits)
                             â”‚  - seo-drift      (baseline exists for URL)
                             â”‚  - seo-ecommerce  (e-commerce detected)
                             â–¼
                    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                    â”‚  Aggregate     â”‚
                    â”‚  Results       â”‚
                    â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
                             â”‚
                             â–¼
                    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                    â”‚  Generate      â”‚
                    â”‚  Health Score  â”‚
                    â”‚  + Action Plan â”‚
                    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Individual Command

```
User Request (e.g., /seo page)
    â”‚
    â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   seo       â”‚  â† Routes to sub-skill
â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   seo-page      â”‚  â† Sub-skill handles directly
â”‚   (SKILL.md)    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## Design Principles

### 1. Progressive Disclosure

- Main SKILL.md stays under 500 lines (per the development rules)
- Reference files loaded on-demand
- Detailed instructions in sub-skills

### 2. Parallel Processing

- Subagents run concurrently during audits
- Independent analyses don't block each other
- Results aggregated after all complete

### 3. Quality Gates

- Built-in thresholds prevent bad recommendations
- Location page limits (30 warning, 50 hard stop)
- Schema deprecation awareness
- FID â†’ INP replacement enforced

### 4. Industry Awareness

- Templates for different business types
- Automatic detection from homepage signals
- Tailored recommendations per industry

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Skill | `seo-{name}/SKILL.md` | `seo-audit/SKILL.md` |
| Agent | `seo-{name}.md` | `seo-technical.md` |
| Reference | `{topic}.md` | `cwv-thresholds.md` |
| Script | `{action}_{target}.py` | `fetch_page.py` |
| Template | `{industry}.md` | `saas.md` |

## Extension Points

### Adding a New Sub-Skill

1. Create `skills/seo-newskill/SKILL.md`
2. Add YAML frontmatter with name and description
3. Write skill instructions
4. Update main `skills/seo/SKILL.md` to route to new skill

### Adding a New Subagent

1. Create `agents/seo-newagent.md`
2. Add YAML frontmatter with name, description, tools
3. Write agent instructions
4. Reference from relevant skills

### Adding a New Reference File

1. Create file in appropriate `references/` directory
2. Reference in skill with load-on-demand instruction

## Extensions

### Managed Python runtime

Bundled tools are dispatched through `bin/antigravity-seo` and
`scripts/runtime.py`, never through a working-directory-relative Python command.
The launcher resolves Python 3.10 or newer, while the standard-library runtime
provides three operations: `run`, `setup`, and read-only `doctor`.

Plugin environments live under persistent `CLAUDE_PLUGIN_DATA`. Manual installs
keep the compatible `~/.claude/skills/seo/.venv` location. A state marker records
the runtime schema, requirements SHA-256, Python major and minor version, public
plugin version, and browser state. Requirements, runtime-schema, or Python ABI
changes require explicit setup; a version-only difference remains compatible and
is refreshed on the next setup. Environment replacement is staged and rolled
back if validation or marker publication fails.

`run` accepts only allowlisted script basenames or a contained extension script.
It forwards arguments without a shell, preserves child exit codes, forces UTF-8
child streams, and uses the same persistent Playwright browser directory created
by setup.

Extensions are opt-in add-ons that integrate external data sources via MCP servers. They live in `extensions/<name>/` and ship their own install / uninstall scripts.

```
extensions/
â”œâ”€â”€ dataforseo/               # DataForSEO MCP integration
â”‚   â”œâ”€â”€ README.md
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ install.ps1
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ uninstall.ps1
â”‚   â”œâ”€â”€ field-config.json
â”‚   â”œâ”€â”€ skills/seo-dataforseo/SKILL.md
â”‚   â”œâ”€â”€ agents/seo-dataforseo.md
â”‚   â””â”€â”€ docs/DATAFORSEO-SETUP.md
â”‚
â”œâ”€â”€ banana/                   # AI image generation via Gemini
â”‚   â”œâ”€â”€ README.md
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ skills/seo-image-gen/SKILL.md
â”‚   â”œâ”€â”€ agents/seo-image-gen.md
â”‚   â”œâ”€â”€ scripts/              # Python fallback scripts (stdlib only)
â”‚   â”œâ”€â”€ references/           # 7 reference files (prompt engineering, models, presets)
â”‚   â””â”€â”€ docs/BANANA-SETUP.md
â”‚
â”œâ”€â”€ firecrawl/                # Firecrawl MCP for full-site crawling
â”‚   â”œâ”€â”€ README.md
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ install.ps1
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ uninstall.ps1
â”‚   â””â”€â”€ skills/seo-firecrawl/SKILL.md
â”‚
â”œâ”€â”€ ahrefs/                   # Ahrefs MCP for backlinks + organic data
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ install.ps1
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ skills/seo-ahrefs/SKILL.md
â”‚   â””â”€â”€ docs/AHREFS-SETUP.md
â”‚
â”œâ”€â”€ seranking/                # SE Ranking AI Share-of-Voice tracking
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ install.ps1
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ skills/seo-seranking/SKILL.md
â”‚   â””â”€â”€ docs/SERANKING-SETUP.md
â”‚
â”œâ”€â”€ profound/                 # Profound LLM citation tracking
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ install.ps1
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ skills/seo-profound/SKILL.md
â”‚   â””â”€â”€ docs/PROFOUND-SETUP.md
â”‚
â”œâ”€â”€ bing-webmaster/           # Bing Webmaster Tools + IndexNow
â”‚   â”œâ”€â”€ install.sh
â”‚   â”œâ”€â”€ install.ps1
â”‚   â”œâ”€â”€ uninstall.sh
â”‚   â”œâ”€â”€ skills/seo-bing/SKILL.md
â”‚   â””â”€â”€ docs/BING-WEBMASTER-SETUP.md
â”‚
â””â”€â”€ unlighthouse/             # Multi-page Lighthouse runner (local)
    â”œâ”€â”€ install.sh
    â”œâ”€â”€ install.ps1
    â”œâ”€â”€ uninstall.sh
    â”œâ”€â”€ skills/seo-unlighthouse/SKILL.md
    â””â”€â”€ docs/UNLIGHTHOUSE-SETUP.md
```

### Available Extensions

| Extension | Package (pinned) | What it adds |
|-----------|------------------|--------------|
| **DataForSEO** | `dataforseo-mcp-server@2.8.10` | Live SERP data, keyword research, backlinks, on-page analysis, business listings, AI visibility, LLM mention tracking |
| **Banana Image Gen** | `@ycse/nanobanana-mcp@1.1.1` | AI image generation for SEO assets via Gemini (OG images, hero images, product photos, infographics, batch) |
| **Firecrawl** | `firecrawl-mcp@3.11.0` | Full-site crawling and URL discovery for audits |
| **Ahrefs** | `@ahrefs/mcp@0.0.11` | Backlinks and organic keyword data via the official `@ahrefs/mcp` server |
| **SE Ranking** | SE Ranking API | AI Share-of-Voice across ChatGPT, Gemini, Perplexity, AI Overviews, and AI Mode |
| **Profound** | Profound API | LLM citation tracking with time-series data |
| **Bing Webmaster** | Bing Webmaster Tools API | Bing Webmaster Tools + IndexNow URL submission |
| **Unlighthouse** | `unlighthouse@0.13.5` | Multi-page Lighthouse runner, runs locally |

### Extension Convention

1. Self-contained in `extensions/<name>/`
2. Own `install.sh` (and `install.ps1` where Windows is supported) that copies files and configures MCP (where applicable)
3. Own `uninstall.sh` (and `uninstall.ps1` where present) that reverses installation
4. Installs the sub-skill mirror to the plugin's skill directory
5. Installs the sub-agent mirror to the plugin's agent directory (extensions that ship one; lighter extensions are skill-only)
6. Merges MCP config into `~/.claude/settings.json` non-destructively
7. MCP server versions are pinned (`@<version>`) for supply-chain stability

