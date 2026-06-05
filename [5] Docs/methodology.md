# Methodology

Melbourne Freeway & Arterial Network — Operational Performance & Congestion Dashboard

This document explains how the dataset was built, how the operational-pressure proxy was derived, and why the approach is defensible. The work is operational reporting that uses transport data — it is not a transport-engineering study, and it does not claim measured travel-time reliability.

---

## 1. Data sources

| Source | Role | Status |
|---|---|---|
| TIRTL 15-minute volume / classification / speed CSVs (Jan, Feb, Apr 2026) | Fact data | Used |
| TIRTL Sites CSV | Site dimension | Used |
| DTP Managed Roads GeoJSON | Road classification / corridor reference | Used |
| AADT 2019 GeoJSON | Annual average daily traffic | **Considered and rejected** |
| SCATS VSDATA (April 2026) | Signal/volume data | **Considered and rejected** |

**Why AADT 2019 was rejected:** the data is pre-pandemic and too stale to represent current conditions, so blending it with 2026 observations would have introduced a structural bias.

**Why SCATS was rejected:** it carries no speed dimension and arrives in an awkward wide format. Speed is central to the operational-pressure proxy, so SCATS could not support the core metric.

These two are documented here, rather than silently dropped, so the source-selection reasoning is on the record.

### Time window
- **Included:** 1 January – 30 April 2026 (89 days of data).
- **March 2026 absent:** not available on the Data.Vic portal at the time of analysis (likely device outages or a QA hold). The analysis does not require a continuous time series, so the gap is documented and non-blocking.
- **December 2025 excluded by choice:** the Christmas / New Year / summer-holiday period contaminates a "typical conditions" baseline.
- **May 2026 excluded by choice:** only 22 days were available at download, which would skew weekday/weekend ratios.

---

## 2. Loading the raw data

The three monthly folders (~90 daily CSVs, 30–55MB each) were bulk-loaded into an all-VARCHAR landing table, then cast into typed columns in a single pass. Two practical constraints shaped the approach:

- **SQL Server Express caps each database at 10GB.** The raw fact table is never duplicated; all downstream work is built as lookups and aggregated summaries against a single source copy.
- **Never run a per-row correlated subquery against the 87.5M-row table.** All heavy operations summarise the big table to a small temporary result in one pass (`GROUP BY` / `SELECT DISTINCT … INTO`), then join the small result — avoiding repeated full scans.

A row-count reconciliation (Q0) confirmed the curated layer matches the raw exactly: **20,851,152 rows / 1,492,421,312 vehicles**.

---

## 3. Cleaning and standardising fields

- **Site dimension:** 406 sites loaded and enriched with corridor and region groupings. Two sites on Princes Fwy West (309, 329) had commas inside quoted names that broke the comma-split load and lost their coordinates; both were corrected manually. They were the only two quoted rows in the sites file.
- **Direction:** raw headings (N/S/E/W) mapped to friendly labels (Northbound, etc.) with an explicit sort order.
- **Vehicle class:** classes 0–14 grouped to the corrected **Austroads boundary — Heavy = classes 3–12** (≈14.8% of the network), Light = 1–2, Unclassified = 0/13/14. This overturned an earlier working assumption that had Heavy near 5%; the correction was made against source and flagged rather than changed quietly.
- **Activity flags:** `is_active_in_data` (297 sites reported) and `is_core` (245 sites active on all 89 days) support ranking stability — rankings default to core sites so intermittent sensors don't distort the order.

---

## 4. Defining time periods

Peak windows were validated empirically from the data rather than assumed, on a weekday non-holiday basis:

- The network is **volume-dominant in the afternoon** (the single busiest hour is 4pm).
- A modest but real **directional tidal signal** exists: westbound leads in the morning, eastbound in the afternoon.

The locked 15-minute period definitions are: **AM Peak 07:00–08:45 · PM Peak 15:00–17:45 · Early AM Build-up 06:00–06:45**, with Off-peak and Inter-peak filling the remainder.

The period sort key is built from `hour_of_day` rather than from `period_type` itself — building a sort column from the column it sorts creates a circular dependency, and routing all non-peak hours to a single value keeps each category to exactly one sort value.

---

## 5. The operational-pressure proxy

Speed observations are binned (31 text bands), so the method works on bin distributions, not continuous speed. The proxy is **site-relative**, never absolute:

1. **Per-site baseline.** For each site, the off-peak volume-weighted median speed defines that site's "normal." Off-peak is read from a single source of truth (`dim time_period.period_type = 'Off-peak'`).
2. **Low-speed share.** For each site × 15-minute interval, the proxy is the volume-weighted percentage of vehicles sitting in speed bins below that site's baseline median — that is, the share of traffic running below its own normal speed.
3. **Pressure signal.** High low-speed share combined with high volume is the operational-pressure signal. Results are aggregated to surface recurring patterns, not one-off incidents.

**Why site-relative, not absolute:** different roads carry different speed limits, so a fixed threshold (e.g. "below 40km/hr") is meaningless across a mixed freeway/arterial network. Anchoring each site to its own off-peak normal makes the comparison fair. Because medians land on bin midpoints (`.5` values), the method claims no false continuous-speed precision.

### The 6am investigation
The proxy initially flagged 06:00–06:30 as top-pressure across the network. Rather than dismiss it as a free-flow artifact, the result was validated against free-flow (2am), AM-peak (7am) and PM-peak (4pm) speed and volume, both network-wide and at corridor level. The conclusion: the network-wide 6am signal is **demand onset**, not congestion pressure, so it was carved out as a separate "Early AM Build-up" period and the formal AM Peak was kept at 07:00–08:45. Severe site-level breakdown remains corridor-specific. The first and corrected proxy scripts are both retained as a record of the iterative analysis.

---

## 6. Identifying monitoring priorities and bottleneck candidates

Two complementary rankings are produced, and they deliberately disagree:

- **"Worst" (slowest relative to normal):** highest low-speed share at peak — e.g. M80 site 225 (71.9%) and Princes Fwy West site 333 (70.6%).
- **"Highest priority" (busy *and* slow):** a 0–100 score blending volume rank with stress rank — e.g. the busy M1 sites 166, 25, 173.

The disagreement is intentional: the slowest site is not always the one worth acting on first; a moderately slow site carrying very high volume can matter more. Surfacing both keeps the recommendation honest.

---

## 7. Dashboard metrics

The Power BI model is a four-dimension star (`fact_traffic` ← `dim site`, `dim date`, `dim time_period`, `dim vehicle_class`), with the summary views attached per visual. Core measures — total observed volume, volume-weighted average speed (90.1 network), peak-period volume, AM/PM split, weekday/weekend/holiday volume, and Heavy Vehicle Share (14.8%) — all reconcile to the 1,492,421,312 anchor. Speed axes are zoomed to the operational band (starting at 20km/hr) while volume axes start at zero.

---

## 8. Why the approach is defensible

- **Reconciled end to end.** Two independent paths from raw both total to 1,492,421,312, so there is no silent join error behind the headline numbers.
- **Honest metric.** The pressure indicator is described as a site-relative proxy off the low-speed tail — the share of traffic running below its own normal speed — never as measured delay or travel-time reliability.
- **Empirically grounded periods.** Peak windows come from the data, and a surprising early-morning result was investigated and reframed rather than inflated.
- **Scoped to the analyst's lane.** The output prioritises monitoring and operational response; it does not make engineering or capital-investment conclusions.
