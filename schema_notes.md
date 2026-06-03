# Schema Design Notes

## Why these 6 tables?

### `annotators`
Stores the human reviewers who evaluate model predictions. Includes `experience_level` (junior/mid/senior) so queries can segment performance by seniority — useful for identifying training needs.

### `apparel_items`
The catalogue of items the AI model predicts on. `difficulty_level` is key — hard items (jackets, ethnic wear) consistently show lower model confidence. This column powers the category-level accuracy analysis.

### `model_evaluations` (fact table)
The core table. Every row = one evaluation event. `is_correct` (boolean) is the primary KPI column. `confidence_score` comes from the model itself and is used to detect low-confidence predictions before they're reviewed.

### `quality_flags`
Separate from evaluations to keep the fact table clean. An evaluation can have zero or one flag. Flag types: `low_confidence`, `mislabel`, `ambiguous`, `duplicate`. `resolved` tracks whether QA has acted on it.

### `daily_targets`
Tracks the SLA: each annotator has a daily output target (20 evals/day). Comparing `target_count` vs `actual_count` gives the SLA compliance metric.

### `weekly_summaries`
Pre-aggregated for reporting speed. In a real pipeline, this would be populated by a scheduled SQL job or stored procedure each Monday. Connects directly to Power BI for the weekly dashboard.

---

## Design Decisions

- Used `BOOLEAN` for `is_correct` instead of 0/1 INT — cleaner for `AVG(is_correct::int)` pattern
- `confidence_score` is `NUMERIC(4,3)` — stores values like `0.873` precisely without float drift
- All foreign keys reference `SERIAL` primary keys — simple and portable
- `DROP TABLE IF EXISTS` at the top allows clean re-runs during development
