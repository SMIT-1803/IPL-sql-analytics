-- Index on striker_key: speeds up selective single-player lookups

DROP INDEX IF EXISTS idx_fact_striker;
CREATE INDEX idx_fact_striker ON fact_delivery (striker_key);