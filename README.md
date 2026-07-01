# IPL Ball-by-Ball Analytics (PostgreSQL)

A PostgreSQL analytics database built on Indian Premier League ball-by-ball data.
The project models raw delivery data into a star schema and answers analytical
questions — scoring leaders, phase-wise performance, death-over economy, form
trends, and dot-ball streaks — using SQL (window functions, CTEs, gaps-and-islands).

## Data

Source: [Cricsheet](https://cricsheet.org/) — IPL match data in the "Ashwin" CSV format.

The dataset is **not included in this repository**. To run this project, download
the IPL CSV from Cricsheet, and place `all_matches.csv` into the `data/` folder.

Data © Cricsheet, used under their terms.

## Tech

- PostgreSQL 17
- psql / TablePlus

## Schema

Star schema: one fact table (`fact_delivery`, grain = one ball) surrounded by
dimensions (`dim_match`, `dim_player`, `dim_team`, `dim_venue`).

- `dim_player` is a role-playing dimension (striker, non-striker, bowler, dismissed).
- `dim_venue` is referenced via `dim_match` (venue is a match-level attribute).
- Phase (powerplay / middle / death) is derived at query time, not stored.

_ER diagram: to be added._

## Project structure

```text
ipl-analytics/
├── data/                 # CSV folder (Add all_matches.csv here)
├── sql/
│   └── 01_schema.sql     # staging + dimensions + fact DDL
└── README.md
```
## Status

- [x] 1. Environment setup
- [x] 2. Data acquisition
- [x] 3. Schema design + DDL
- [ ] 4. Ingestion (staging load + transform)
- [ ] 5. Validation
- [ ] 6. Core analytics
- [ ] 7. Advanced analytics
- [ ] 8. Optimization (indexing + EXPLAIN ANALYZE)
- [ ] 9. Polish