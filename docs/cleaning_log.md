# Cleaning log

Rules are applied in order; each row's count reflects only rows not already removed by an earlier rule.
SQL: [`sql/02_clean_deliveries.sql`](../sql/02_clean_deliveries.sql)

| Step | Rule | Rows removed | Rows remaining |
| --- | --- | --- | --- |
| 0 | Raw load (nulls encoded as "NA" handled at load) | — | 197,428 |
| 1 | Drop rows with no actual delivery time | 7 | 197,421 |
| 2 | Drop rows with no estimated driving duration | 526 | 196,895 |
| 3 | Drop rows with no market or protocol after store-level fill | 3 | 196,892 |
| 4 | Drop orphan order dated before 2015-01-21 | 1 | 196,891 |
| 5 | Drop deliveries under 5 or over 180 minutes | 140 | 196,751 |

**Final:** 196,751 rows (99.7% of raw; 677 removed).

## Flags (rows kept, marked for analysis)

| Flag | Rows | Meaning |
| --- | --- | --- |
| `has_load_data = 0` | 16,283 | Dasher load counts missing (16,202 originally null) or negative (81, set to null) |
| `busy_exceeds_onshift = 1` | 40,256 | Busy Dashers exceed on-shift Dashers; likely Dashers finishing after shift end |