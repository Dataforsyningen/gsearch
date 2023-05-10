-- Create table with text combinations and number of occurences
-- Helper to create data.
DROP TABLE IF EXISTS basic.husnummer_count;
CREATE TABLE basic.matrikel_count (
    tekstelement text,
    forekomster int,
    PRIMARY KEY (tekstelement)
);

-- inserts into husnummer_count
WITH number_of_chars AS (
    SELECT generate_series(1,8) i
)
INSERT INTO basic.husnummer_count (tekstelement, forekomster)
SELECT
    substring(lower(vejnavn) FROM 1 FOR i),
    count(*)
FROM
    basic.husnummer, number_of_chars
WHERE vejnavn IS NOT null
GROUP BY
    substring(lower(vejnavn) FROM 1 FOR i)
HAVING
    count(1) > 1000
ON CONFLICT DO NOTHING;
