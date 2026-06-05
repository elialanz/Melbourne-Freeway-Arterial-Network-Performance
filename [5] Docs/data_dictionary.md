# Data Dictionary

Melbourne Freeway & Arterial Network — Operational Performance & Congestion Dashboard

This document describes the curated data model that powers the Power BI dashboard. It covers the source layer, the reporting (`rpt`) layer that Power BI consumes, and the DAX measures built on top. All figures reconcile to a single anchor: **1,492,421,312 observed vehicles** across **89 days** (1 Jan – 30 Apr 2026).

---

## 1. Layers at a glance

| Layer | Object type | Loaded into Power BI? | Purpose |
|---|---|---|---|
| `stg` (staging) | Raw fact table | No | Source of truth (87.5M rows). Never loaded to Power BI. |
| `rpt` (reporting) | 2 tables + 12 views | Yes | Curated star schema + business-logic views the dashboard reads. |

The dashboard reads only the curated `rpt` layer. The raw 87.5M-row table is retained as the source of truth but is too large and too granular to publish.

---

## 2. Source / staging layer

### `stg.tirtl_raw`
Raw, all-row landing table loaded from the TIRTL daily CSVs. Retained as the audit trail; not consumed by any reporting view.

| Column | Type | Description |
|---|---|---|
| `date` | DATE | Observation date. |
| `time_bin` | VARCHAR | 15-minute interval label (e.g. `0:00`). |
| `site` | VARCHAR | Detector site identifier. |
| `heading` | VARCHAR | Direction of travel (N / S / E / W). |
| `vehicle_class` | TINYINT | Austroads class 0–14. |
| `speed_bin` | VARCHAR | Speed band text label (e.g. `70km/hr to < 75km/hr`). |
| `volume` | INT | Vehicle count in that interval / class / speed band. |
| `source_file` | VARCHAR | Origin CSV (lineage). |
| `loaded_at` | DATETIME | Load timestamp. |

Row count: **87,500,000 (approx.) raw → 20,851,152 curated**.

---

## 3. Reporting fact tables (`rpt`)

### `rpt.fact_traffic`
The model spine. Aggregated fact table, **20,851,152 rows**, total volume **1,492,421,312** across 89 days and 297 active sites.

- **Grain:** `date_key` × `time_bin` × `site_id` × `heading` × `vehicle_class`

| Column | Type | Description |
|---|---|---|
| `date_key` | DATE | Joins to `dim date`. |
| `time_bin` | TIME(0) | Joins to `dim time_period`. |
| `site_id` | VARCHAR | Joins to `dim site`. |
| `heading` / `Direction` | VARCHAR | Raw heading (N/S/E/W); `Direction` is the friendly label (Northbound, etc.). |
| `vehicle_class` | TINYINT | Joins to `dim vehicle_class`. |
| `volume` | INT | Observed vehicle count. |
| `speed_volume_product` | BIGINT | Volume × bin-midpoint speed, pre-computed for volume-weighted average speed. |

### `rpt.site_speed_distribution`
Independent speed-band distribution, **43,264 rows** at `site_id × period_type × speed_bin × volume`. Built from raw on a separate path from `fact_traffic` so the two totals can be reconciled against each other — two roads to the same 1,492,421,312, confirming no silent join error.

---

## 4. Dimension views (`rpt`)

### `dim site` — 406 rows
| Column | Description |
|---|---|
| `site_id` (PK) | Detector identifier. |
| `site_name` | Full site description. |
| `road_name` | NULL by design (corridor covers the reporting need). |
| `corridor` | Corridor grouping (see below). |
| `latitude`, `longitude` | Coordinates for the map. |
| `region` | Greater Melbourne / Regional Victoria / Special Device. |
| `is_active_in_data` | TRUE if the site reported any data in window. |
| `is_core` | TRUE for the 245 sites active on all 89 days (used for ranking stability). |
| `notes` | Free-text flags (e.g. over-height detection devices). |

**Site coverage:** 406 reference · 297 active · 245 core (all 89 days) · 109 dormant.

**Corridor grouping (active sites):** M1 Monash/West Gate Fwy 158 · Princes Fwy West 46 · Tullamarine Fwy 35 · Other Metro Road 26 · M80 Ring Road 20 · Regional Freeway/Highway 6 · West Gate 6. (M1 has 226 reference sites but only 158 live — 68 dormant, the largest pool of idle sensors.)

### `dim date` — 120 rows
Calendar 1 Jan – 30 Apr 2026.

| Column | Description |
|---|---|
| `date_key` (PK) | Calendar date. |
| `is_weekday`, `is_weekend` | Day-type booleans. |
| `is_public_holiday` | TRUE on the 7 in-window Victorian holidays. |
| `public_holiday_name` | Holiday label. |
| `day_type` | Weekday / Weekend / Holiday. |
| `is_in_data` | TRUE where the data window covers that date. |

In-window VIC holidays: 1 Jan (New Year's Day), 26 Jan (Australia Day), 3 Apr (Good Friday), 4 Apr, 5 Apr (Easter), 6 Apr (Easter Monday), 25 Apr (ANZAC Day).

### `dim time_period` — 96 bins
| Column | Description |
|---|---|
| `time_bin` (PK, TIME(0)) | 15-minute interval. |
| `hour_of_day`, `minute_of_hour` | Components. |
| `time_label` | Display label. |
| `period_type` | Off-peak / Early AM Build-up / AM Peak / Inter-peak / PM Peak. |
| `is_peak`, `is_am_peak`, `is_pm_peak` | Period booleans. |
| `period_sort` | Sort key built from `hour_of_day` (independent of `period_type` to avoid a circular sort dependency). |

| Period | Bins | Window |
|---|---|---|
| Off-peak | 48 | 00:00–05:45 + 18:00–23:45 |
| Early AM Build-up | 4 | 06:00–06:45 |
| AM Peak | 8 | 07:00–08:45 |
| Inter-peak | 24 | 09:00–14:45 |
| PM Peak | 12 | 15:00–17:45 |

### `dim vehicle_class` — 15 rows (classes 0–14)
| Column | Description |
|---|---|
| `vehicle_class` (PK) | Austroads class 0–14. |
| `vehicle_group_v2` | Grouping on the corrected Austroads boundary: **Light = classes 1–2, Heavy = classes 3–12, Unclassified = 0/13/14**. |

Network mix: Light 84.76% · Heavy 14.77% · Unclassified 0.47%.

### `dim speed_bin` — 31 rows
| Column | Description |
|---|---|
| `speed_bin` (PK) | Text label (e.g. `70km/hr to < 75km/hr`). |
| `speed_low`, `speed_high` | Numeric band edges (`speed_high` NULL for `150km/hr +`). |
| `speed_mid` | Band midpoint (used for volume-weighted speed; `150km/hr +` → 152.5). |
| `sort_order` | Display order. |

---

## 5. Reporting / summary views (`rpt`)

These carry pre-built business logic and are bound directly to their dashboard visuals rather than to the star.

| View | Feeds |
|---|---|
| `view_site_pressure_summary` | Page 1 top pressure locations, KPI cards, map. |
| `view_direction_performance` | Page 2 directional comparison (westbound AM / eastbound PM). |
| `view_peak_period_summary` | Page 3 weekday / weekend / holiday × peak. |
| `view_vehicle_mix_summary` | Page 2 vehicle-class mix. |
| `view_speed_distribution` | Page 2 speed profile, Page 3 volume–speed. |
| `view_congestion_profile` | Page 3 congestion-proxy heatmap. |
| `view_bottleneck_candidates` | Page 2 bottleneck list. |

**Object count:** 12 views (5 dimension + 7 summary) + 2 tables (`fact_traffic`, `site_speed_distribution`).

---

## 6. DAX measures

All measures reconcile to the 1,492,421,312 anchor.

| Measure | Definition | Result |
|---|---|---|
| Total Observed Volume | `SUM('rpt fact_traffic'[volume])` | 1,492,421,312 |
| Avg Daily Volume | `DIVIDE([Total Observed Volume], DISTINCTCOUNT('dim date'[date_key]))` | ~7.6M/day at M1 |
| Volume-Weighted Avg Speed | `DIVIDE(SUM([speed_volume_product]), SUM([volume]))` | 90.1 (network) |
| Peak Period Volume | filtered `is_peak = TRUE` | 472,780,879 |
| AM Peak Volume | `period_type = "AM Peak"` | 160,753,457 |
| PM Peak Volume | `period_type = "PM Peak"` | 312,027,422 |
| Weekday Volume | `is_weekday = TRUE` AND `is_public_holiday = FALSE` | 1,059,436,638 |
| Weekend Volume | `is_weekend = TRUE` | 380,364,722 |
| Heavy Vehicle Volume | `vehicle_group_v2 = "Heavy"` | 220,380,071 |
| Heavy Vehicle Share % | `DIVIDE([Heavy Vehicle Volume], [Total Observed Volume])` | 14.8% |

> Note on booleans: flags import to Power BI as TRUE/FALSE, so filters use `= TRUE` / `= FALSE`, not `= 1`.

---

## 7. Naming conventions

- Dimensions are named with a space, not a dotted prefix: `dim site`, `dim date`, `dim time_period`, `dim vehicle_class`, `dim speed_bin`.
- Fact: `rpt fact_traffic`.
- Views: `rpt view_…`.
