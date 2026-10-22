# Retain and align legacy writing site — jnapolitano-site

Approved visual authority: littlelink commit ae3e9062d8e06a1158af74a29cbd8b549d82b3e2, docs/branding/2026-10-22/brand-contract.md. Preserve all writing, media, URLs, feed behavior and access boundaries. No redirect, retirement, DNS, content rewrite, workflow change or dependency migration.

Scope: additive local template hook and static CSS/font assets with OFL licenses. Text-only site title; 22px identity, 28px reading titles, 16px body, paper/ink/stone, restrained dark slate. Existing social/menu/theme/toc controls retained. No decorative images added; meaningful article media preserved.

GitHub Pages evidence 2026-10-22: Pages API confirms CNAME justin-napolitano.com, latest deployment main6e228aff85cca5843fbd2a0eeb6e6f71eaed4d96 on2025-11-23. Branch origin/main8f993bc is current source; original brutal draft preserved. Exact workflow Zola0.19.2 baseline builds64pages+2sections (7orphans,6existing missing-date/weight warnings). macOS sandbox network-config panic requires unsandboxed build, no runtime or content change. Existing light/dark controls retained. Rollback focused CSS/hook commit.

Validation after implementation: exact pinned toolchain build passes. Before/after HTML route sets identical (64 HTML output files); rendered text identical across all outputs; XML feed outputs unchanged. Only additive CSS/font assets and template hook change. Browser QA remains blocked pending authorized fallback.
