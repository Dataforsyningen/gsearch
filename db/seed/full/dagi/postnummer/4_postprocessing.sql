ALTER TABLE basic.postnummer
    DROP COLUMN IF EXISTS textsearchable_plain_col;

ALTER TABLE basic.postnummer
    ADD COLUMN textsearchable_plain_col tsvector
    GENERATED ALWAYS AS (setweight(to_tsvector('simple', postnummer), 'A') ||
                         setweight(to_tsvector('simple', split_part(postnummernavn, ' ', 1)), 'B') ||
                         setweight(to_tsvector('simple', split_part(postnummernavn, ' ', 2)), 'C') ||
                         setweight(to_tsvector('simple', basic.split_and_endsubstring (postnummernavn, 3)), 'D'))
    STORED;

ALTER TABLE basic.postnummer
    DROP COLUMN IF EXISTS textsearchable_unaccent_col;

ALTER TABLE basic.postnummer
    ADD COLUMN textsearchable_unaccent_col tsvector
    GENERATED ALWAYS AS (setweight(to_tsvector('basic.septima_fts_config', postnummer), 'A') ||
                         setweight(to_tsvector('basic.septima_fts_config', split_part(postnummernavn, ' ', 1)), 'B') ||
                         setweight(to_tsvector('basic.septima_fts_config', split_part(postnummernavn, ' ', 2)), 'C') ||
                         setweight(to_tsvector('basic.septima_fts_config', basic.split_and_endsubstring (postnummernavn, 3)), 'D'))
    STORED;

ALTER TABLE basic.postnummer
    DROP COLUMN IF EXISTS textsearchable_phonetic_col;

ALTER TABLE basic.postnummer
    ADD COLUMN textsearchable_phonetic_col tsvector
    GENERATED ALWAYS AS (setweight(to_tsvector('simple', postnummer), 'A') ||
                         setweight(to_tsvector('simple', fonetik.fnfonetik (split_part(postnummernavn, ' ', 1), 2)), 'B') ||
                         setweight(to_tsvector('simple', fonetik.fnfonetik (split_part(postnummernavn, ' ', 2), 2)), 'C') ||
                         setweight(to_tsvector('simple', basic.split_and_endsubstring_fonetik (postnummernavn, 3)), 'D'))
    STORED;