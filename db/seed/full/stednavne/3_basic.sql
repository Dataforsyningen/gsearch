DROP TABLE IF EXISTS basic_initialloading.stednavn;

WITH agg_stednavne_officiel AS (
    SELECT
        objectid,
        skrivemaade
    FROM
        stednavne_udstilling.stednavne_udstilling o
    WHERE
        navnestatus <> 'uofficielt'
),
agg_stednavne_uofficiel AS (
    SELECT
        objectid,
        string_agg(skrivemaade, ',') AS skrivemaader
    FROM
        stednavne_udstilling.stednavne_udstilling u
    WHERE
        navnestatus = 'uofficielt'
    GROUP BY
        objectid
),
agg_stednavne AS (
    SELECT
        su.objectid,
        id_lokalid,
        navnefoelgenummer,
        visningstekst,
        o.skrivemaade AS skrivemaade,
        u.skrivemaader AS skrivemaade_uofficiel,
        navnestatus,
        "type",
        subtype,
        kommunekode,
        st_force2d (geometri_udtyndet) AS geometri
    FROM
        stednavne_udstilling.stednavne_udstilling su
    LEFT JOIN agg_stednavne_officiel o ON
        o.objectid = su.objectid
    LEFT JOIN agg_stednavne_uofficiel u ON
        u.objectid = su.objectid
    GROUP BY
        su.objectid,
        id_lokalid,
        navnefoelgenummer,
        visningstekst,
        o.skrivemaade,
        u.skrivemaader,
        navnestatus,
        "type",
        subtype,
        kommunekode,
        geometri_udtyndet
),
visningstekst_uofficel_merge AS (
    SELECT
        objectid,
        REPLACE(agg_s.visningstekst, '(', '(' || skrivemaade || ', ') AS visningstekst -- Uofficel skrivemaade shall always have the officel skrivemadde in visningstekst
    FROM
        agg_stednavne agg_s
    WHERE
        navnestatus = 'uofficielt'
      AND skrivemaade IS NOT NULL -- Nogle stednavne har ikke en officel skrivemaade, dem ønsker vi ikke at matche med
)
SELECT
    DISTINCT id_lokalid AS id, -- Need DISTINCT for not getting duplicates of the same row if there is two or more skrivemaade_uofficel
    (
        CASE WHEN agg_s.navnestatus = 'uofficielt' AND skrivemaade IS NOT NULL -- Nogle stednavne har ikke en officel skrivemaade, dem ønsker vi ikke at matche med
            THEN
                 vum.visningstekst
            ELSE
                 agg_s.visningstekst
            END
        ) AS visningstekst,
    (
        CASE WHEN agg_s.navnestatus = 'uofficielt' AND skrivemaade IS NOT NULL -- Nogle stednavne har ikke en officel skrivemaade, dem ønsker vi ikke at matche med
            THEN
                 replace(replace(vum.visningstekst, ' - ', ' '), '-', ' ')
            ELSE
                 replace(replace(agg_s.visningstekst, ' - ', ' '), '-', ' ')
            END
        ) AS visningstekst_nohyphen,
    skrivemaade,
    skrivemaade_uofficiel,
    type AS stednavn_type,
    subtype AS stednavn_subtype,
    kommunekode,
    st_multi (st_union (geometri)) AS geometri,
    st_envelope (st_collect (geometri)) AS bbox
INTO basic_initialloading.stednavn
FROM
    agg_stednavne agg_s
    LEFT JOIN visningstekst_uofficel_merge vum ON
        vum.objectid = agg_s.objectid
GROUP BY
    id,
    vum.visningstekst,
    agg_s.visningstekst,
    visningstekst_nohyphen,
    skrivemaade,
    skrivemaade_uofficiel,
    agg_s.navnestatus,
    type,
    subtype,
    kommunekode;