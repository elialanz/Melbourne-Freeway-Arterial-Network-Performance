# Melbourne Freeway & Arterial Network
### Operational Performance & Congestion Dashboard

MSSSQL and Power BI Reporting Project.
This Project shows transport operations teams **where and when** Melbourne's freeways and major arterial roads run under the most pressure.
It facilitates monitoring, planning, and response with the goal of point actions where it matters most.

> **View the dashboard:** download the Power BI file (.pbix) from Google Drive — *requires Power BI Desktop (free, Windows)*: `PASTE GOOGLE DRIVE LINK HERE`
> Prefer a quick look? Screenshots of all four pages are at the bottom.

---

## What it does

Melbourne's road network has hundreds of roadside detectors counting vehicles and recording their speed. On their own, those readings are just a wall of numbers. This project turns roughly **1.5 billion** of them into a four-page dashboard that answers practical questions: which corridors are busiest, when the daily peaks hit, which direction the pressure flows, and which specific locations run slower than they normally should.

It is built as an **operational reporting tool** — the kind a network operations or planning team would use to decide where to focus attention. It is not a traffic-engineering study and does not claim to measure real travel times.

## The data

- **Source:** TIRTL roadside detectors, published as open data on Data.Vic, plus the Department of Transport's managed-roads map for corridor context.
- **Size:** about **1.5 billion vehicle observations** across **89 days** (January–April 2026).
- **Honest note:** March data wasn't available in the open dataset, so the period covers January, February, and April. This is documented, not hidden.

Across the whole network the average recorded speed was about **90 km/h**, afternoons were busier than mornings, and heavy vehicles (trucks and similar) made up roughly **15%** of traffic.

## What the dashboard shows

Four pages, each answering one question in plain terms:

1. **Executive Overview** — the big picture: total volume, average speed, peak demand, and the locations under the most pressure.
2. **Site & Direction Performance** — how traffic flows by direction, including the tidal pattern: heading into the city in the morning, back out in the afternoon.
3. **Peak Period & Operational Pressure** — when and where the network runs slowest, shown as a time-of-day heatmap plus a priority list of busy-and-slow sites.
4. **Recommendations & Data Confidence** — what to act on, and an honest summary of how far the data can be pushed.

## Headline findings

- **Afternoons carry more traffic than mornings** — useful for timing operational staffing and response.
- **Pressure is directional and tidal** (westbound in the morning, eastbound in the afternoon), so it's better managed by direction than as one lump.
- **West Gate shows the strongest early-morning slow-running** — a clear first place to focus a morning response.
- **A handful of M1 and Princes Freeway ramps are both very busy and frequently slow** (85,000–99,000 vehicles a day, running below their own normal speed about 70% of the time) — the best candidates for engineering attention.

*A note on wording:* "slow-running" means a location is moving **slower than its own normal**, measured from the detector speed readings. It is a **proxy** for pressure, compared within a corridor — not a measure of how long anyone's trip actually took.

## What I'd recommend acting on

1. **Manage the peaks by direction**, not as one network-wide event.
2. **Start the morning operational response at West Gate**, where early-morning slow-running is highest.
3. **Send engineering effort to the busy-and-slow M1 / Princes ramps** first.

## Honest limitations

- The "slow-running" measure is a **site-relative proxy**, not measured delay or travel-time reliability.
- Detector readings are **observations**, not official counts.
- Detector coverage is **uneven** across corridors, so figures are best read against how densely a corridor is monitored — and compared **within** a corridor, not across different ones.
- The period excludes March (data unavailable). Two other sources (older annual averages and a separate signal dataset) were considered and deliberately set aside; the reasons are in the methodology notes.

## Tools

- **SQL Server** — the main engine: loading the raw detector files, cleaning them, and building the summarised tables and views.
- **Power BI** — the reporting layer: the data model, the calculations, and the four dashboard pages.

## How it's organised

```
1_Data/         source and processed data (large raw files kept out of this repo)
2_SQL/          all SQL scripts, in run order (01 to 06)
3_PowerBI/      the dashboard file (also on Google Drive — link above)
4_Screenshots/  page images
5_Docs/         data dictionary, methodology, limitations, case study
README.md       this file
```

**To reproduce:** run the SQL scripts in `2_SQL` in numbered order to rebuild the tables and views, then open the Power BI file and point it at the resulting data. The full step-by-step is in the methodology notes.

## Screenshots

**1. Executive Overview**

![Executive Overview](./[4]%20Screenshots/01_executive_overview.png)

**2. Site & Direction Performance**

![Site and Direction Performance](./[4]%20Screenshots/02_site_and_direction.png)

**3. Peak Period & Operational Pressure**

![Peak Period and Operational Pressure](./[4]%20Screenshots/03_peak_period_pressure.png)

**4. Recommendations & Data Confidence**

![Recommendations and Data Confidence](./[4]%20Screenshots/04_recommendations.png)

---

*Built as a portfolio project demonstrating end-to-end reporting: raw open data, SQL modelling, and a clean, decision-focused Power BI dashboard — with honest framing of what the data can and can't say.*
