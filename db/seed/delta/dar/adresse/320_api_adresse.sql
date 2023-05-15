SELECT '320_api_adresse.sql ' || now();


DROP TYPE IF EXISTS api.adresse CASCADE;

CREATE TYPE api.adresse AS (
    id text,
    kommunekode text,
    kommunenavn text,
    vejkode text,
    vejnavn text,
    husnummer text,
    etagebetegnelse text,
    doerbetegnelse text,
    postnummer text,
    postnummernavn text,
    visningstekst text,
    geometri geometry,
    vejpunkt_geometri geometry
);

COMMENT ON TYPE api.adresse IS 'Adresse';

COMMENT ON COLUMN api.adresse.id IS 'ID på adresse';

COMMENT ON COLUMN api.adresse.kommunekode IS 'Kommunekode(r) for kommune(r) der ligger i eller optil en adresse';

COMMENT ON COLUMN api.adresse.kommunenavn IS 'Kommunenavn for en adresse';

COMMENT ON COLUMN api.adresse.vejkode IS 'Vejkode for en adresse';

COMMENT ON COLUMN api.adresse.vejnavn IS 'Vejnavn for en adresse';

COMMENT ON COLUMN api.adresse.husnummer IS 'Husnummer på adresse';

COMMENT ON COLUMN api.adresse.etagebetegnelse IS 'Etagebetegnelse for adresse';

COMMENT ON COLUMN api.adresse.doerbetegnelse IS 'Dørbetegnelse for adresse';

COMMENT ON COLUMN api.adresse.postnummer IS 'Postnummer på adresse';

COMMENT ON COLUMN api.adresse.postnummernavn IS 'Postnummernavn på adresse';

COMMENT ON COLUMN api.adresse.visningstekst IS 'Fulde adresse';

COMMENT ON COLUMN api.adresse.vejpunkt_geometri IS 'Geometri for vejpunkt i EPSG:25832';

COMMENT ON COLUMN api.adresse.geometri IS 'Geometri for adgangspunkt i EPSG:25832';

DROP TABLE IF EXISTS basic.adresse;

-- Gets the list of problem roadnames
-- SELECT DISTINCT a.vejnavn FROM basic.adresse a WHERE vejnavn ~ '\d';

WITH adresser AS (
    SELECT
        a.id,
        a.adressebetegnelse as visningstekst,
        a.doerbetegnelse AS doerbetegnelse,
        a.etagebetegnelse,
        h.husnummertekst AS husnummer,
        h.navngivenvej_id,
        h.sortering AS husnummer_sortering,
        n.vejnavn,
        h.vejkode,
        h.kommunekode,
        k.navn AS kommunenavn,
        p.postnr AS postnummer,
        p.navn AS postnummernavn,
        st_force2d (COALESCE(ap.geometri)) AS geometri,
        st_force2d (COALESCE(ap2.geometri)) AS vejpunkt_geometri
    FROM
        dar.adresse a
        JOIN (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY navngivenvej_id ORDER BY NULLIF ((substring(husnummertekst::text
                FROM '[0-9]*')), '')::int,
                    substring(husnummertekst::text
                FROM '[0-9]*([A-Z])') NULLS FIRST) AS sortering
            FROM
                dar.husnummer) h ON a.husnummer_id = h.id::uuid
            JOIN dar.navngivenvej n ON n.id = h.navngivenvej_id::uuid
            JOIN dar.postnummer p ON p.id = h.postnummer_id::uuid
            JOIN dar.adressepunkt ap ON ap.id = h.adgangspunkt_id
            JOIN dar.adressepunkt ap2 ON ap2.id = h.vejpunkt_id
            JOIN dagi_500.kommuneinddeling k ON k.kommunekode = h.kommunekode
)
SELECT
    a.id,
    a.visningstekst,
    a.vejnavn,
    a.vejkode,
    coalesce(a.husnummer::text, ''::text) AS husnummer,
    coalesce(a.etagebetegnelse, ''::text) AS etagebetegnelse,
    coalesce(a.doerbetegnelse, ''::text) AS doerbetegnelse,
    a.postnummer,
    a.postnummernavn,
    a.kommunekode,
    a.kommunenavn,
    nv.textsearchable_plain_col_vej,
    nv.textsearchable_unaccent_col_vej,
    nv.textsearchable_phonetic_col_vej,
    a.navngivenvej_id,
    a.husnummer_sortering,
    ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY CASE lower(a.etagebetegnelse)
        WHEN '' THEN
            -10
        WHEN 'k3' THEN
            -3
        WHEN 'k2' THEN
            -2
        WHEN 'kl' THEN
            -1
        WHEN 'st' THEN
            0
        ELSE
            NULLIF ((substring(a.etagebetegnelse FROM '[0-9]*')), '')::int
        END,
        CASE lower(a.doerbetegnelse)
        WHEN 'tv' THEN
            -3
        WHEN 'mf' THEN
            -2
        WHEN 'th' THEN
            -1
        ELSE
            NULLIF ((substring(a.doerbetegnelse FROM '^[^0-9]*([0-9]+)')), '')::int
        END) AS sortering,
        st_multi (a.geometri) AS geometri,
    st_multi (a.vejpunkt_geometri) AS vejpunkt_geometri INTO basic.adresse
FROM
    adresser a
    JOIN basic.navngivenvej nv ON a.navngivenvej_id = nv.id;


-- Inserts into tekst_forekomst
WITH a AS (SELECT generate_series(1,8) a)
    INSERT INTO basic.tekst_forekomst (ressource, tekstelement, forekomster)
    SELECT
    'adresse',
    substring(lower(vejnavn) FROM 1 FOR a),
    count(*)
    FROM
    basic.adresse am
    CROSS JOIN a
    WHERE vejnavn IS NOT null
    GROUP BY
    substring(lower(vejnavn) FROM 1 FOR a)
    HAVING
    count(1) > 1000
    ON CONFLICT DO NOTHING;


-- USE TEXTSEARCHABLE COLUMNS FROM NAVNGIVENVEJ INSTEAD OF RECOMPUTING THEM
-- append husnummer, etage, and dør
ALTER TABLE basic.adresse
    DROP COLUMN IF EXISTS textsearchable_plain_col;

ALTER TABLE basic.adresse
    ADD COLUMN textsearchable_plain_col tsvector
        GENERATED ALWAYS AS (textsearchable_plain_col_vej ||
                             setweight(to_tsvector('simple', husnummer), 'D') ||
                             setweight(to_tsvector('simple', etagebetegnelse), 'D') ||
                             setweight(to_tsvector('simple', doerbetegnelse), 'D') ||
                             setweight(to_tsvector('simple', postnummer), 'D') ||
                             setweight(to_tsvector('simple', postnummernavn), 'D'))
        STORED;

ALTER TABLE basic.adresse
    DROP COLUMN IF EXISTS textsearchable_unaccent_col;

ALTER TABLE basic.adresse
    ADD COLUMN textsearchable_unaccent_col tsvector
        GENERATED ALWAYS AS (textsearchable_unaccent_col_vej ||
                             setweight(to_tsvector('simple', husnummer), 'D') ||
                             setweight(to_tsvector('simple', etagebetegnelse), 'D') ||
                             setweight(to_tsvector('simple', doerbetegnelse), 'D') ||
                             setweight(to_tsvector('simple', postnummer), 'D') ||
                             setweight(to_tsvector('simple', postnummernavn), 'D'))
        STORED;

ALTER TABLE basic.adresse
    DROP COLUMN IF EXISTS textsearchable_phonetic_col;

ALTER TABLE basic.adresse
    ADD COLUMN textsearchable_phonetic_col tsvector
        GENERATED ALWAYS AS (textsearchable_phonetic_col_vej ||
                             setweight(to_tsvector('simple', husnummer), 'D') ||
                             setweight(to_tsvector('simple', etagebetegnelse), 'D') ||
                             setweight(to_tsvector('simple', doerbetegnelse), 'D') ||
                             setweight(to_tsvector('simple', postnummer), 'D') ||
                             setweight(to_tsvector('simple', postnummernavn), 'D'))
        STORED;

CREATE INDEX ON basic.adresse USING GIN (textsearchable_plain_col);

CREATE INDEX ON basic.adresse USING GIN (textsearchable_unaccent_col);

CREATE INDEX ON basic.adresse USING GIN (textsearchable_phonetic_col);

CREATE INDEX ON basic.adresse (lower(vejnavn), navngivenvej_id, husnummer_sortering, sortering);

DROP FUNCTION IF EXISTS api.adresse (text, text, int, int);

CREATE OR REPLACE FUNCTION api.adresse (input_tekst text, filters text, sortoptions int, rowlimit int)
    RETURNS SETOF api.adresse
    LANGUAGE plpgsql
    STABLE
    AS $function$
DECLARE
    max_rows integer;
    query_string text;
    plain_query_string text;
    stmt text;
BEGIN
    -- Initialize
    max_rows = 1000;
    IF rowlimit > max_rows THEN
        RAISE 'rowlimit skal være <= %', max_rows;
    END IF;
    IF filters IS NULL THEN
        filters = '1=1';
    END IF;
    IF btrim(input_tekst) = ANY ('{.,-, '', \,}') THEN
        input_tekst = '';
    END IF;

    SELECT
        -- removes repeated whitespace and '-'
        regexp_replace(input_tekst, '[- \s]+', ' ', 'g')
    INTO input_tekst;

    -- Build the query_string (converting vejnavn of input to phonetic)
    WITH tokens AS (
        SELECT
            UNNEST(string_to_array(btrim(input_tekst), ' ')) t
    )
    SELECT
        string_agg(fonetik.fnfonetik (t, 2), ':* & ') || ':*'
    FROM
        tokens
    INTO query_string;

    -- build the plain version of the query string for ranking purposes
    WITH tokens AS (
        SELECT
            -- Splitter op i temp-tabel hver hvert vejnavn-ord i hver sin raekke.
            UNNEST(string_to_array(btrim(input_tekst), ' ')) t
    )
    SELECT
        string_agg(t, ':* & ') || ':*'
    FROM
        tokens
    INTO plain_query_string;

-- Hvis en input_tekst kun indeholder bogstaver og har over 1000 resultater, kan soegningen tage lang tid.
-- Dette er dog ofte soegninger, som ikke noedvendigvis giver mening. (fx. husnummer = 's'
-- eller adresse = 'od').
-- Saa for at goere api'et hurtigere ved disse soegninger, er der to forskellige queries
-- i denne funktion. Den ene bliver brugt, hvis der er over 1000 forekomster.
-- Vi har hardcoded antal forekomster i tabellen: `tekst_forekomst`.
-- Dette gaelder for:
-- - husnummer
-- - adresse
-- - matrikel
-- - navngivenvej
-- - stednavn

-- Et par linjer nede herfra, tilfoejes der et `|| ''å''`. Det er et hack,
-- for at representere den alfanumerisk sidste vej, der starter med `%s`

    IF (
        SELECT
            COALESCE(forekomster, 0)
        FROM
            basic.tekst_forekomst
        WHERE
            ressource = 'adresse'
        AND lower(input_tekst) = tekstelement ) > 1000
        AND filters = '1=1'
    THEN
        stmt = format(E'SELECT
                id::text,
                kommunekode::text,
                kommunenavn::text,
                vejkode::text,
                vejnavn::text,
                husnummer::text,
                etagebetegnelse::text,
                doerbetegnelse::text,
                postnummer::text,
                postnummernavn::text,
                visningstekst::text,
                geometri,
                vejpunkt_geometri
            FROM
                basic.adresse
            WHERE
                lower(vejnavn) >= lower(''%s'')
                AND lower(vejnavn) <= lower(''%s'') || ''å''
            ORDER BY
                lower(vejnavn),
                navngivenvej_id,
                husnummer_sortering,
                sortering
            LIMIT $3;', input_tekst, input_tekst);
        --RAISE NOTICE 'stmt=%', stmt;
        RETURN QUERY EXECUTE stmt
        USING query_string, plain_query_string, rowlimit;
    ELSE
        -- Execute and return the result
        stmt = format(E'SELECT
                id::text,
                kommunekode::text,
                kommunenavn::text,
                vejkode::text,
                vejnavn::text,
                husnummer::text,
                etagebetegnelse::text,
                doerbetegnelse::text,
                postnummer::text,
                postnummernavn::text,
                visningstekst::text,
                geometri,
                vejpunkt_geometri
            FROM
                basic.adresse
            WHERE (
                textsearchable_phonetic_col @@ to_tsquery(''simple'', $1)
                OR textsearchable_unaccent_col @@ to_tsquery(''simple'', $2)
                OR textsearchable_plain_col @@ to_tsquery(''simple'', $2)
            )
            AND %s
            ORDER BY
                basic.combine_rank(
                    $2,
                    $2,
                    textsearchable_plain_col,
                    textsearchable_unaccent_col,
                    ''simple''::regconfig,
                    ''basic.septima_fts_config''::regconfig
                ) desc,
                ts_rank_cd(
                    textsearchable_phonetic_col,
                    to_tsquery(''simple'',$1)
                )::double precision desc,
                lower(vejnavn),
                navngivenvej_id,
                husnummer_sortering,
                sortering
            LIMIT $3;', filters);
        --RAISE NOTICE 'stmt=%', stmt;
        RETURN QUERY EXECUTE stmt
        USING query_string, plain_query_string, rowlimit;
    END IF;
END
$function$;

-- Test cases:
/*
 SELECT (api.adresse('park allé 2 1',NULL, 1, 100)).*;
 SELECT (api.adresse('ålbor 5 1. th.',NULL, 1, 100)).*;
 SELECT (api.adresse('søborg h 100',NULL, 1, 100)).*;
 SELECT (api.adresse('aarhus 3',NULL, 1, 100)).*;
 SELECT (api.adresse('århus 3',NULL, 1, 100)).*;
 SELECT (api.adresse('holbæk',NULL, 1, 100)).*;
 SELECT (api.adresse('vinkel 3',NULL, 1, 100)).*;
 SELECT (api.adresse('sve',NULL, 1, 100)).*;
 SELECT (api.adresse('s',NULL, 1, 100)).*;
 */
