-- ============================================================
--  AI Model Quality Tracker
--  Based on Google Apparel AI Evaluation Pipeline
--  Author: Ritika Bisht | GlobalLogic-inspired Project
-- ============================================================


-- ============================================================
--  SECTION 1: CREATE TABLES
-- ============================================================

DROP TABLE IF EXISTS weekly_summaries;
DROP TABLE IF EXISTS quality_flags;
DROP TABLE IF EXISTS daily_targets;
DROP TABLE IF EXISTS model_evaluations;
DROP TABLE IF EXISTS apparel_items;
DROP TABLE IF EXISTS annotators;

CREATE TABLE annotators (
    annotator_id     SERIAL PRIMARY KEY,
    name             VARCHAR(100) NOT NULL,
    team             VARCHAR(50),
    experience_level VARCHAR(20) CHECK (experience_level IN ('junior','mid','senior')),
    join_date        DATE,
    status           VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','inactive'))
);

CREATE TABLE apparel_items (
    item_id          SERIAL PRIMARY KEY,
    category         VARCHAR(50),
    subcategory      VARCHAR(50),
    brand            VARCHAR(50),
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('easy','medium','hard')),
    image_url        VARCHAR(200)
);

CREATE TABLE model_evaluations (
    eval_id           SERIAL PRIMARY KEY,
    item_id           INT REFERENCES apparel_items(item_id),
    annotator_id      INT REFERENCES annotators(annotator_id),
    eval_date         DATE NOT NULL,
    model_prediction  VARCHAR(100),
    ground_truth      VARCHAR(100),
    is_correct        BOOLEAN NOT NULL,
    confidence_score  NUMERIC(4,3) CHECK (confidence_score BETWEEN 0 AND 1),
    time_taken_sec    INT
);

CREATE TABLE quality_flags (
    flag_id      SERIAL PRIMARY KEY,
    eval_id      INT REFERENCES model_evaluations(eval_id),
    flag_type    VARCHAR(50) CHECK (flag_type IN ('low_confidence','mislabel','ambiguous','duplicate')),
    flagged_by   VARCHAR(100),
    flag_date    DATE,
    resolved     BOOLEAN DEFAULT FALSE
);

CREATE TABLE daily_targets (
    target_id    SERIAL PRIMARY KEY,
    annotator_id INT REFERENCES annotators(annotator_id),
    target_date  DATE,
    target_count INT,
    actual_count INT
);

CREATE TABLE weekly_summaries (
    summary_id   SERIAL PRIMARY KEY,
    annotator_id INT REFERENCES annotators(annotator_id),
    week_start   DATE,
    total_evals  INT,
    accuracy_pct NUMERIC(5,2),
    avg_time_sec NUMERIC(6,1),
    flags_raised INT DEFAULT 0
);


-- ============================================================
--  SECTION 2: SAMPLE DATA
-- ============================================================

-- Annotators (30 team members, mirrors GlobalLogic team)
INSERT INTO annotators (name, team, experience_level, join_date, status) VALUES
('Priya Sharma',      'Team A', 'senior', '2022-01-10', 'active'),
('Rahul Mehta',       'Team A', 'mid',    '2022-03-15', 'active'),
('Sneha Kapoor',      'Team A', 'junior', '2023-06-01', 'active'),
('Arjun Nair',        'Team A', 'mid',    '2022-07-20', 'active'),
('Divya Reddy',       'Team A', 'senior', '2021-11-05', 'active'),
('Karan Patel',       'Team B', 'junior', '2023-08-12', 'active'),
('Meena Iyer',        'Team B', 'mid',    '2022-05-18', 'active'),
('Vikram Singh',      'Team B', 'senior', '2021-09-30', 'active'),
('Ananya Das',        'Team B', 'junior', '2023-07-04', 'active'),
('Rohan Gupta',       'Team B', 'mid',    '2022-10-22', 'active'),
('Neha Joshi',        'Team C', 'mid',    '2022-04-11', 'active'),
('Amit Kumar',        'Team C', 'senior', '2021-06-25', 'active'),
('Pooja Verma',       'Team C', 'junior', '2023-09-01', 'active'),
('Suresh Pillai',     'Team C', 'mid',    '2022-08-14', 'active'),
('Asha Rao',          'Team C', 'senior', '2021-03-17', 'active'),
('Deepak Choudhary',  'Team D', 'junior', '2023-05-20', 'active'),
('Kavita Menon',      'Team D', 'mid',    '2022-02-08', 'active'),
('Siddharth Tiwari',  'Team D', 'senior', '2021-12-01', 'active'),
('Ritu Bhatia',       'Team D', 'junior', '2023-10-15', 'active'),
('Gaurav Saxena',     'Team D', 'mid',    '2022-09-27', 'active'),
('Sunita Mishra',     'Team E', 'senior', '2021-07-14', 'active'),
('Manish Agarwal',    'Team E', 'mid',    '2022-06-03', 'active'),
('Tanya Bhatt',       'Team E', 'junior', '2023-04-19', 'active'),
('Nikhil Soni',       'Team E', 'mid',    '2022-11-30', 'active'),
('Geeta Pandey',      'Team E', 'junior', '2023-11-01', 'active'),
('Yash Malhotra',     'Team F', 'senior', '2021-05-09', 'active'),
('Ishaan Trivedi',    'Team F', 'mid',    '2022-12-16', 'active'),
('Payal Khanna',      'Team F', 'junior', '2023-02-28', 'active'),
('Rajesh Dubey',      'Team F', 'mid',    '2022-01-21', 'inactive'),
('Simran Gill',       'Team F', 'junior', '2023-03-07', 'active');

-- Apparel items (50 items across categories)
INSERT INTO apparel_items (category, subcategory, brand, difficulty_level, image_url) VALUES
('Tops',      'T-Shirt',       'H&M',       'easy',   'img/tops/tshirt_001.jpg'),
('Tops',      'Blouse',        'Zara',       'medium', 'img/tops/blouse_002.jpg'),
('Tops',      'Crop Top',      'Myntra',     'easy',   'img/tops/croptop_003.jpg'),
('Tops',      'Shirt',         'Allen Solly','medium', 'img/tops/shirt_004.jpg'),
('Tops',      'Polo',          'Lacoste',    'easy',   'img/tops/polo_005.jpg'),
('Bottoms',   'Jeans',         'Levi\'s',    'medium', 'img/bottoms/jeans_006.jpg'),
('Bottoms',   'Trousers',      'Peter England','medium','img/bottoms/trousers_007.jpg'),
('Bottoms',   'Shorts',        'Nike',       'easy',   'img/bottoms/shorts_008.jpg'),
('Bottoms',   'Skirt',         'Zara',       'medium', 'img/bottoms/skirt_009.jpg'),
('Bottoms',   'Leggings',      'Adidas',     'easy',   'img/bottoms/leggings_010.jpg'),
('Outerwear', 'Jacket',        'Mango',      'hard',   'img/outer/jacket_011.jpg'),
('Outerwear', 'Blazer',        'Van Heusen', 'hard',   'img/outer/blazer_012.jpg'),
('Outerwear', 'Coat',          'Marks&Spencer','hard', 'img/outer/coat_013.jpg'),
('Outerwear', 'Hoodie',        'Puma',       'medium', 'img/outer/hoodie_014.jpg'),
('Outerwear', 'Windbreaker',   'Nike',       'hard',   'img/outer/windbreaker_015.jpg'),
('Dresses',   'Maxi Dress',    'AND',        'hard',   'img/dresses/maxi_016.jpg'),
('Dresses',   'Mini Dress',    'Vero Moda',  'medium', 'img/dresses/mini_017.jpg'),
('Dresses',   'Wrap Dress',    'W',          'hard',   'img/dresses/wrap_018.jpg'),
('Dresses',   'Shift Dress',   'Pantaloons', 'medium', 'img/dresses/shift_019.jpg'),
('Dresses',   'A-Line Dress',  'FabIndia',   'hard',   'img/dresses/aline_020.jpg'),
('Footwear',  'Sneakers',      'Adidas',     'easy',   'img/footwear/sneakers_021.jpg'),
('Footwear',  'Heels',         'Steve Madden','hard',  'img/footwear/heels_022.jpg'),
('Footwear',  'Loafers',       'Clarks',     'medium', 'img/footwear/loafers_023.jpg'),
('Footwear',  'Sandals',       'Bata',       'easy',   'img/footwear/sandals_024.jpg'),
('Footwear',  'Boots',         'Woodland',   'hard',   'img/footwear/boots_025.jpg'),
('Accessories','Handbag',      'Caprese',    'hard',   'img/acc/handbag_026.jpg'),
('Accessories','Sunglasses',   'Ray-Ban',    'medium', 'img/acc/sunglasses_027.jpg'),
('Accessories','Scarf',        'Pashmoda',   'easy',   'img/acc/scarf_028.jpg'),
('Accessories','Belt',         'Tommy Hilfiger','medium','img/acc/belt_029.jpg'),
('Accessories','Watch',        'Titan',      'medium', 'img/acc/watch_030.jpg'),
('Ethnicwear', 'Saree',        'FabIndia',   'hard',   'img/ethnic/saree_031.jpg'),
('Ethnicwear', 'Kurta',        'Manyavar',   'medium', 'img/ethnic/kurta_032.jpg'),
('Ethnicwear', 'Salwar Suit',  'Biba',       'hard',   'img/ethnic/salwar_033.jpg'),
('Ethnicwear', 'Lehenga',      'Kalki',      'hard',   'img/ethnic/lehenga_034.jpg'),
('Ethnicwear', 'Dhoti',        'Manyavar',   'hard',   'img/ethnic/dhoti_035.jpg'),
('Sportswear', 'Sports Bra',   'Nike',       'easy',   'img/sport/sportsbra_036.jpg'),
('Sportswear', 'Track Pants',  'Reebok',     'easy',   'img/sport/trackpants_037.jpg'),
('Sportswear', 'Jersey',       'Adidas',     'medium', 'img/sport/jersey_038.jpg'),
('Sportswear', 'Compression Top','Under Armour','medium','img/sport/compression_039.jpg'),
('Sportswear', 'Running Shorts','Puma',      'easy',   'img/sport/runshorts_040.jpg'),
('Innerwear',  'Bra',          'Jockey',     'medium', 'img/inner/bra_041.jpg'),
('Innerwear',  'Briefs',       'Jockey',     'easy',   'img/inner/briefs_042.jpg'),
('Innerwear',  'Vest',         'Rupa',       'easy',   'img/inner/vest_043.jpg'),
('Innerwear',  'Boxers',       'Dollar',     'easy',   'img/inner/boxers_044.jpg'),
('Innerwear',  'Thermal Set',  'Lux',        'medium', 'img/inner/thermal_045.jpg'),
('Bags',       'Backpack',     'Wildcraft',  'medium', 'img/bags/backpack_046.jpg'),
('Bags',       'Tote Bag',     'Lavie',      'easy',   'img/bags/tote_047.jpg'),
('Bags',       'Clutch',       'Hidesign',   'hard',   'img/bags/clutch_048.jpg'),
('Bags',       'Sling Bag',    'Baggit',     'medium', 'img/bags/sling_049.jpg'),
('Bags',       'Duffel Bag',   'Skybags',    'medium', 'img/bags/duffel_050.jpg');


-- Model evaluations: 520 rows generated via cross-join logic
-- Covers Jan 2024 – Dec 2024 (12 months, realistic accuracy distribution)

INSERT INTO model_evaluations (item_id, annotator_id, eval_date, model_prediction, ground_truth, is_correct, confidence_score, time_taken_sec)
SELECT
    ((ROW_NUMBER() OVER () - 1) % 50) + 1                          AS item_id,
    ((ROW_NUMBER() OVER () - 1) % 29) + 1                          AS annotator_id,
    DATE '2024-01-01' + (((ROW_NUMBER() OVER ()) * 17) % 366)      AS eval_date,
    CASE ((ROW_NUMBER() OVER () * 7) % 5)
        WHEN 0 THEN 'Tops'
        WHEN 1 THEN 'Bottoms'
        WHEN 2 THEN 'Outerwear'
        WHEN 3 THEN 'Dresses'
        ELSE 'Footwear'
    END                                                              AS model_prediction,
    CASE ((ROW_NUMBER() OVER () * 7) % 5)
        WHEN 0 THEN 'Tops'
        WHEN 1 THEN 'Bottoms'
        WHEN 2 THEN 'Outerwear'
        WHEN 3 THEN 'Dresses'
        ELSE 'Footwear'
    END                                                              AS ground_truth,
    CASE WHEN (ROW_NUMBER() OVER () % 10) < 9 THEN TRUE ELSE FALSE END AS is_correct,
    ROUND((0.70 + (((ROW_NUMBER() OVER () * 13) % 30)) * 0.01)::numeric, 3) AS confidence_score,
    25 + ((ROW_NUMBER() OVER () * 11) % 95)                         AS time_taken_sec
FROM generate_series(1, 520);

-- Introduce realistic failures: some annotators have lower accuracy
UPDATE model_evaluations
SET is_correct = FALSE
WHERE annotator_id IN (3, 9, 13, 19, 25)
  AND eval_date BETWEEN '2024-04-01' AND '2024-06-30';

-- Low confidence on hard items
UPDATE model_evaluations
SET confidence_score = ROUND((0.50 + ((eval_id * 7) % 20) * 0.01)::numeric, 3)
WHERE item_id IN (
    SELECT item_id FROM apparel_items WHERE difficulty_level = 'hard'
);

-- Quality flags: ~50 flagged evaluations
INSERT INTO quality_flags (eval_id, flag_type, flagged_by, flag_date, resolved)
SELECT
    eval_id,
    CASE (eval_id % 4)
        WHEN 0 THEN 'low_confidence'
        WHEN 1 THEN 'mislabel'
        WHEN 2 THEN 'ambiguous'
        ELSE 'duplicate'
    END,
    'QA-Bot',
    eval_date + 1,
    CASE WHEN eval_id % 3 = 0 THEN TRUE ELSE FALSE END
FROM model_evaluations
WHERE is_correct = FALSE
LIMIT 50;

-- Daily targets for all 29 active annotators over 30 days
INSERT INTO daily_targets (annotator_id, target_date, target_count, actual_count)
SELECT
    a.annotator_id,
    d.target_date,
    20 AS target_count,
    CASE
        WHEN a.experience_level = 'senior' THEN 18 + (a.annotator_id % 5)
        WHEN a.experience_level = 'mid'    THEN 15 + (a.annotator_id % 6)
        ELSE                                    12 + (a.annotator_id % 7)
    END AS actual_count
FROM annotators a
CROSS JOIN (
    SELECT DATE '2024-01-01' + s AS target_date
    FROM generate_series(0, 29) s
) d
WHERE a.status = 'active';

-- Weekly summaries: 12 weeks per active annotator
INSERT INTO weekly_summaries (annotator_id, week_start, total_evals, accuracy_pct, avg_time_sec, flags_raised)
SELECT
    a.annotator_id,
    DATE '2024-01-01' + (w.wk * 7) AS week_start,
    CASE a.experience_level
        WHEN 'senior' THEN 95 + (w.wk % 10)
        WHEN 'mid'    THEN 80 + (w.wk % 12)
        ELSE               65 + (w.wk % 15)
    END AS total_evals,
    CASE
        WHEN a.experience_level = 'senior' THEN ROUND((92 + (w.wk % 6))::numeric, 2)
        WHEN a.experience_level = 'mid'    THEN ROUND((85 + (w.wk % 8))::numeric, 2)
        ELSE                                    ROUND((78 + (w.wk % 10))::numeric, 2)
    END AS accuracy_pct,
    ROUND((40 + ((a.annotator_id + w.wk) % 40))::numeric, 1) AS avg_time_sec,
    CASE WHEN (a.annotator_id + w.wk) % 7 = 0 THEN 1 + (w.wk % 3) ELSE 0 END AS flags_raised
FROM annotators a
CROSS JOIN (SELECT generate_series(0,11) AS wk) w
WHERE a.status = 'active';


-- ============================================================
--  SECTION 3: QUERIES
-- ============================================================

-- ---------------------------------------------------------
--  Query 1: Overall model accuracy by apparel category
-- ---------------------------------------------------------
SELECT
    a.category,
    COUNT(*)                                              AS total_evals,
    SUM(CASE WHEN e.is_correct THEN 1 ELSE 0 END)        AS correct_evals,
    ROUND(AVG(e.is_correct::int) * 100, 2)               AS accuracy_pct,
    ROUND(AVG(e.confidence_score), 3)                    AS avg_confidence,
    ROUND(AVG(e.time_taken_sec), 1)                      AS avg_time_sec
FROM model_evaluations e
JOIN apparel_items a ON e.item_id = a.item_id
GROUP BY a.category
ORDER BY accuracy_pct DESC;


-- ---------------------------------------------------------
--  Query 2: Annotator performance ranking
-- ---------------------------------------------------------
SELECT
    an.name,
    an.team,
    an.experience_level,
    COUNT(*)                                              AS evals_done,
    SUM(CASE WHEN e.is_correct THEN 1 ELSE 0 END)        AS correct,
    ROUND(AVG(e.is_correct::int) * 100, 2)               AS accuracy_pct,
    ROUND(AVG(e.time_taken_sec), 1)                      AS avg_time_sec,
    RANK()     OVER (ORDER BY AVG(e.is_correct) DESC)    AS accuracy_rank,
    DENSE_RANK() OVER (
        PARTITION BY an.team
        ORDER BY AVG(e.is_correct) DESC
    )                                                     AS rank_within_team
FROM model_evaluations e
JOIN annotators an ON e.annotator_id = an.annotator_id
GROUP BY an.annotator_id, an.name, an.team, an.experience_level
ORDER BY accuracy_rank;


-- ---------------------------------------------------------
--  Query 3: Weekly accuracy trend with 4-week rolling average
-- ---------------------------------------------------------
WITH weekly AS (
    SELECT
        DATE_TRUNC('week', eval_date)::date              AS week_start,
        COUNT(*)                                         AS total_evals,
        ROUND(AVG(e.is_correct::int) * 100, 2)          AS accuracy_pct
    FROM model_evaluations e
    GROUP BY DATE_TRUNC('week', eval_date)
)
SELECT
    week_start,
    total_evals,
    accuracy_pct,
    ROUND(
        AVG(accuracy_pct) OVER (
            ORDER BY week_start
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ), 2
    )                                                    AS rolling_4wk_avg,
    ROUND(
        accuracy_pct - LAG(accuracy_pct) OVER (ORDER BY week_start), 2
    )                                                    AS week_on_week_change
FROM weekly
ORDER BY week_start;


-- ---------------------------------------------------------
--  Query 4: Underperforming batch detection
-- ---------------------------------------------------------
WITH weekly_acc AS (
    SELECT
        ws.annotator_id,
        an.name,
        an.team,
        ws.week_start,
        ws.accuracy_pct,
        ws.flags_raised
    FROM weekly_summaries ws
    JOIN annotators an ON ws.annotator_id = an.annotator_id
)
SELECT
    name,
    team,
    week_start,
    accuracy_pct,
    flags_raised,
    CASE
        WHEN accuracy_pct < 80  THEN 'Critical — below 80%'
        WHEN accuracy_pct < 90  THEN 'Warning — below 90%'
        ELSE                         'On track'
    END                                                  AS status,
    ROUND(
        accuracy_pct - AVG(accuracy_pct) OVER (
            PARTITION BY annotator_id
        ), 2
    )                                                    AS deviation_from_personal_avg
FROM weekly_acc
ORDER BY accuracy_pct ASC;


-- ---------------------------------------------------------
--  Query 5: Reusable view — full quality dashboard
--  (Connect this directly to Power BI)
-- ---------------------------------------------------------
CREATE OR REPLACE VIEW vw_quality_dashboard AS
SELECT
    an.annotator_id,
    an.name,
    an.team,
    an.experience_level,
    COUNT(e.eval_id)                                     AS total_evals,
    ROUND(AVG(e.is_correct::int) * 100, 2)              AS accuracy_pct,
    ROUND(AVG(e.confidence_score), 3)                   AS avg_confidence,
    ROUND(AVG(e.time_taken_sec), 1)                     AS avg_time_sec,
    COUNT(f.flag_id)                                    AS total_flags,
    COUNT(CASE WHEN f.resolved THEN 1 END)              AS resolved_flags,
    RANK() OVER (ORDER BY AVG(e.is_correct) DESC)       AS overall_rank,
    RANK() OVER (
        PARTITION BY an.team
        ORDER BY AVG(e.is_correct) DESC
    )                                                    AS team_rank
FROM annotators an
LEFT JOIN model_evaluations e  ON an.annotator_id = e.annotator_id
LEFT JOIN quality_flags f      ON e.eval_id = f.eval_id
WHERE an.status = 'active'
GROUP BY an.annotator_id, an.name, an.team, an.experience_level;

-- Query the dashboard view
SELECT * FROM vw_quality_dashboard ORDER BY overall_rank;


-- ============================================================
--  BONUS: SLA compliance report (daily targets vs actuals)
-- ============================================================
SELECT
    an.name,
    an.team,
    COUNT(*)                                             AS days_tracked,
    ROUND(AVG(dt.actual_count), 1)                      AS avg_daily_output,
    SUM(CASE WHEN dt.actual_count >= dt.target_count
             THEN 1 ELSE 0 END)                         AS days_target_met,
    ROUND(
        SUM(CASE WHEN dt.actual_count >= dt.target_count
                 THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100, 1
    )                                                    AS sla_compliance_pct
FROM daily_targets dt
JOIN annotators an ON dt.annotator_id = an.annotator_id
GROUP BY an.annotator_id, an.name, an.team
ORDER BY sla_compliance_pct DESC;

