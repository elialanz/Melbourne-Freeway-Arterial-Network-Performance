# Limitations

Melbourne Freeway & Arterial Network — Operational Performance & Congestion Dashboard

This dashboard is operational reporting that happens to use transport data. The points below set the boundary on what it does and does not claim.

---

## Data and collection

- The analysis uses available historical detector data — 15-minute volume, vehicle-classification and speed observations from TIRTL detectors, **87.5M raw rows / 1,492,421,312 observed vehicles across 89 days (January–April 2026)**.
- These are detector **observations**, not official traffic counts. They should not be read as authoritative published figures.
- **March 2026 is absent** from the window — it was not available on the Data.Vic portal at the time of analysis. The work does not require a continuous time series, so the gap is documented and non-blocking.
- Sensor coverage is **uneven** across the network (e.g. M1 has 158 live sites; West Gate has 6). Counts should always be read against monitoring density, not treated as a like-for-like comparison between corridors.

## Method

- Operational pressure is measured only through a **proxy indicator**, not direct measurement. "Slow-running" is a **site-relative proxy** built from the low-speed tail of each site's speed distribution — the share of traffic running below its own normal speed — **not measured delay**.
- The proxy is site-relative by design. Figures should be compared **within a corridor, not across corridors**, because each site is anchored to its own off-peak baseline.

## Scope of claims

- The project **does not claim true travel-time reliability or real delay** unless live journey-time / API data is added later.
- The project **does not make engineering conclusions**. Findings such as heavy-vehicle exposure are framed as candidates for further attention, not as proven wear or infrastructure assessments.
- The dashboard is designed for **operational reporting and monitoring prioritisation** — deciding where and when to focus attention — rather than for capital-investment or network-design decisions.

---

*Language used throughout: slow-running, operational pressure, monitoring priority, congestion proxy (site-relative). The dashboard deliberately avoids "true congestion," "real delay," and "travel-time reliability."*
