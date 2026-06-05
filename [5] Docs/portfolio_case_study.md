# Portfolio Case Study

## Melbourne Freeway & Arterial Network — Operational Performance & Congestion Dashboard

A SQL and Power BI reporting framework built on Melbourne arterial and freeway detector data to identify site-level operational pressure, peak-period patterns, and congestion-proxy indicators for transport and infrastructure performance reporting.

---

### Project overview

The network carries **1.49 billion observed vehicles** across 89 days (January–April 2026), captured at 15-minute resolution by roadside detectors across the freeway and arterial network. Raw, this is 87.5M rows — too granular for anyone to act on. This project turns it into a four-page decision-ready dashboard that answers where and when the network is under operational pressure, and where monitoring effort should go.

### Business problem

Transport and operations stakeholders need to know **where and when** freeway and arterial segments experience the highest operational pressure — speed reduction relative to normal, peak demand, and directional load — so they can prioritise monitoring, operational response, and planning. The raw detector feed does not answer that question; it has to be modelled, validated, and framed.

### Stakeholder need

A network operations / performance reporting team that has to decide, with finite resources, which locations and time windows to watch and respond to first. They need a defensible, honest picture — not inflated congestion claims — and they need it to read clearly at an executive level while standing up to scrutiny underneath.

### Data source

- **TIRTL detectors** — 15-minute volume, vehicle-classification and speed observations (Data.Vic), Jan / Feb / Apr 2026.
- **TIRTL Sites CSV** — the site dimension (location, corridor).
- **DTP Managed Roads GeoJSON** — road classification / corridor reference.
- **Considered and rejected:** AADT 2019 (pre-pandemic, too stale) and SCATS VSDATA (no speed dimension, awkward format). Documented in the methodology rather than dropped silently.

March 2026 was unavailable on the portal at analysis time (documented, non-blocking). December 2025 and May 2026 were excluded by choice — holiday contamination and an incomplete month respectively.

### Tools used

SQL Server 2022 Express + SSMS (the analytical engine and main proof), Power BI with Power Query and DAX (the reporting output). Python was used only sparingly for support tasks — the positioning is SQL + Power BI.

### Data preparation

- Bulk-loaded ~90 daily CSVs into an all-VARCHAR landing table, then cast to typed columns in a single pass — working within the 10GB-per-database Express cap by never duplicating the raw fact table.
- Avoided per-row subqueries against the 87.5M-row table (one such pattern caused an hour-long hang); all heavy work summarises the big table once, then joins the small result.
- Fixed two Princes Fwy West sites whose quoted, comma-containing names had broken the load and lost their coordinates.
- **Corrected the Heavy-vehicle definition** to the Austroads boundary (classes 3–12, ≈14.8% of the network), overturning an earlier assumption that put Heavy near 5%. The correction was flagged against source rather than changed quietly.

### SQL modelling

A curated `rpt` layer sits on top of the raw source: an aggregated fact table (`fact_traffic`, 20,851,152 rows), an independent speed-distribution table, five dimension views and seven business-logic summary views. A row-count reconciliation and two independent totals from raw both land on **1,492,421,312** — confirming there is no silent join error behind the numbers.

### Power BI dashboard structure

- **Page 1 — Executive Network Overview:** total volume, volume-weighted average speed (90.1 network), peak-period volume, top pressure locations, AM vs PM, congestion-proxy summary, and a map.
- **Page 2 — Site & Direction Performance:** site ranking by pressure, directional comparison (westbound AM / eastbound PM), speed-band distribution, vehicle-class mix, peak-hour profile, and bottleneck candidates, with slicers across day, corridor, direction and vehicle group.
- **Page 3 — Peak Period & Operational Pressure:** weekday vs weekend vs holiday, Early AM Build-up and AM vs PM, the volume–speed relationship, a congestion-proxy heatmap by site and time, and recommended monitoring windows.
- **Page 4 — Recommendations & Data Confidence:** three prioritised actions, a coverage-density table that frames every figure against how densely each corridor is monitored, and a data / method / limitations panel.

### Key insights

- **The network is afternoon-dominant.** On a weekday non-holiday basis, PM volume (~222M) runs well above AM (~131M), with the single busiest hour at 4pm — and average speed barely differs between the two, so the load is about volume, not breakdown.
- **Demand is tidal by direction.** Westbound leads in the morning, eastbound in the afternoon — a modest but consistent signal that maps cleanly onto a direction-aware operational response.
- **Pressure is concentrated and site-specific.** The slowest-relative-to-normal sites (M80 site 225 at 71.9%, Princes Fwy West site 333 at 70.6%) differ deliberately from the highest-priority sites (busy *and* slow M1 sites 166, 25, 173). The slowest site is not always the one to act on first.
- **A surprising early-morning signal, investigated rather than inflated.** The proxy first flagged 6am as top-pressure network-wide. Validated against free-flow, AM-peak and PM-peak conditions, it proved to be **demand onset**, not congestion — so it was carved out as a separate "Early AM Build-up" period and the formal AM peak kept at 07:00–08:45.

#### Heavy-vehicle exposure — a single genuine pinch-point

Corridor-level heavy share is flat across the network (M80 17.0%, West Gate 15.3%, M1 15.1%, Princes 15.0% against a 14.8% network baseline — no standout). The interesting finding only surfaced at site level, by cross-referencing **heavy volume against heavy share** rather than either alone.

One site is high on both: **PFW 125m East of Kororoit Creek Road (OB), Princes Fwy West** — **1,861,610 heavy vehicles** (the network's #2 by heavy volume) at a **29.9% heavy share** (roughly double the network), with its inbound twin carrying 1.36M at 23.4%. It is the only site that is simultaneously a very high heavy-volume location and a high heavy-share location.

This is framed as **heavy-vehicle exposure — a candidate for prioritised inspection — not as proven wear or an engineering claim.** The analytical point is the reasoning itself: exposure needs *both* volume *and* concentration, and a single metric would have hidden this site. *(Before treating it as a clean full-period figure, confirm the site reported across all 89 days — i.e. that it is active in data — so the comparison is like-for-like.)*

### Recommended actions

1. **Manage peaks by direction** — align operational response to the westbound-AM / eastbound-PM tidal pattern rather than treating peaks as uniform.
2. **Run the morning operational response on West Gate first** — it shows elevated slow-running early (66% early-AM, 60% AM peak) against ~50% elsewhere, easing to 34% off-peak.
3. **Direct engineering attention to the busy-and-slow M1 / Princes ramps** — 85K–99K vehicles/day at roughly 70% of traffic running below its own normal speed.

Each action is a distinct lever — direction, time-and-place, and specific-site — and all trace back to the same site-relative proxy. Network-operator capital decisions (regional investment, new detectors) were deliberately left out as outside the analyst's lane.

### Limitations

Detector observations, not official counts; operational pressure measured through a site-relative proxy, not measured delay; March 2026 absent and sensor coverage uneven, so figures are read against monitoring density and compared within a corridor rather than across; no travel-time-reliability or engineering claims. Full detail in `limitations.md`.

### Skills demonstrated

- SQL data engineering at scale (87.5M rows) within hard storage constraints, with end-to-end reconciliation.
- Dimensional modelling and a clean Power BI star schema with reconciled DAX measures.
- Power Query cleaning, data-quality correction, and a defensible analytical method (site-relative proxy).
- Business framing and stakeholder thinking — turning raw observations into prioritised, defensible actions.
- Analytical judgement: validating a surprising result, correcting a wrong assumption against source, and refusing to overclaim.

### Resume bullet

> Built a SQL and Power BI operational performance dashboard on 1.49B Melbourne traffic observations (87.5M rows), modelling a reconciled star schema and a site-relative congestion proxy to surface peak demand windows, directional load, vehicle-class patterns, and prioritised monitoring locations for transport reporting.

### Interview explanation

The story I lead with is the 6am finding. The proxy first told me the whole network was under pressure at 6am, which looked wrong. Instead of deleting it, I checked it against free-flow, morning-peak and afternoon-peak conditions at both network and corridor level, and worked out it was demand ramping up, not congestion — so I split it into its own "build-up" period and kept the formal peak honest. That's the judgement I want to show: a surprising number is something to investigate, not something to assume is a bug or a headline.

The second story is the heavy-vehicle pinch-point near Kororoit Creek. Corridor-level heavy share is flat, so nothing stood out — until I cross-referenced heavy *volume* against heavy *share* at site level and found one location high on both. I framed it as an exposure candidate for inspection, not proven wear, because the honest version is that wear needs both volume and concentration and I only had the traffic side. The whole project is built that way: site-relative proxy not absolute thresholds, "observations" not "counts," fully reconciled to a single anchor, and recommendations scoped to what an operations analyst can actually defend.
