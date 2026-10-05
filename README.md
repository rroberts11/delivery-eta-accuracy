# delivery-eta-accuracy


## Data

**Source:** [DoorDash ETA Prediction](https://www.kaggle.com/datasets/dharun4772/doordash-eta-prediction) (Kaggle).
197,428 deliveries placed between January 21 and February 18, 2015, across six markets.
DoorDash added noise to obfuscate business details. Money is in cents and durations are in seconds.
Brightbite is a fictional company; the data and the problem are real.

**Time zone.** Timestamps are stored in UTC. Per the data dictionary, every market is in US/Pacific.
All orders fall before daylight saving began on March 8, 2015, so local time = UTC − 8 hours for every row.

### Data quality issues and how they were handled

| Issue | Rows | Handling |
| --- | --- | --- |
| Raw CSV encodes nulls as the text "NA", which made DuckDB read numeric columns as text | All | Loaded with `nullstr = 'NA'` and `TRY_CAST`; null counts validated against pandas for every column |
| Missing market, order protocol, or cuisine category | 987 / 995 / 4,760 | Filled with the store's most common value from its other orders. Recovered 99.7% of market and protocol gaps and 82% of category gaps; 867 remaining categories labeled `unknown` |
| Missing Dasher load data (on-shift, busy, outstanding orders) | 16,262 (8.2%) | Kept and flagged (`has_load_data = 0`). After outlier removal, these orders average 47.4 min vs. 47.6 min for the rest, so the gap is not tied to delivery time. Dropping them would have lost 8% of the data for no benefit |
| One delivery recorded at 141,948 minutes (~98.6 days) | 1 | Removed with the outlier rule below. It alone had inflated the flagged group's average by about 9 minutes |
| Deliveries under 5 or over 180 minutes | 3 / 138 | Removed as physically implausible or abandoned orders |
| Single orphan order dated October 2014, three months before the rest | 1 | Removed so it would not distort the time-based train/test split |
| Negative Dasher counts | 81 | Set to null and flagged as missing load data; the orders themselves were kept |
| Busy Dashers exceed on-shift Dashers | 40,394 (20%) | Kept and flagged (`busy_exceeds_onshift`). Too common to be an error; most likely Dashers finishing deliveries after their shift ends. Tested as a signal of market overload |

**Final dataset:** 196,751 deliveries (99.7% of raw; 677 removed). 16,283 are flagged for missing
Dasher load data and 40,256 for busy Dashers exceeding on-shift Dashers. Full step-by-step counts
are in [`docs/cleaning_log.md`](docs/cleaning_log.md).