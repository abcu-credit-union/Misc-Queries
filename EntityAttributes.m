let
    SQL =
"SELECT
    'P' || PERS.PERSNBR ""Entity"",
    PERS.FIRSTNAME ""First Name"",
    PERS.LASTNAME ""Last Name"",
    PERS.FIRSTNAME || ' ' || LASTNAME ""Full Name"",
    FLOOR(MONTHS_BETWEEN(TRUNC(CURRENT_DATE), PERS.DATEBIRTH)/12) ""Age"",
    OCCPTN.OCCPTNDESC ""Occupation"",
    pInfo.PhoneNbr ""Phone Number(s)""
FROM PERS
LEFT OUTER JOIN OCCPTN
    ON PERS.OCCPTNCD = OCCPTN.OCCPTNCD
LEFT OUTER JOIN
    (SELECT
        PERSPHONE.PERSNBR,
        LISTAGG(PERSPHONE.PHONEUSECD || ' ' || PERSPHONE.AREACD || PERSPHONE.FOREIGNPHONENBR, '; ')
            WITHIN GROUP (ORDER BY PERSPHONE.PHONEUSECD) AS PhoneNbr
    FROM PERSPHONE
    GROUP BY PERSPHONE.PERSNBR) pInfo
    ON PERS.PERSNBR = pInfo.PERSNBR
WHERE
    PERS.DATEDEATH IS NULL",

    BBSource = Table.AddColumn(
        Oracle.Database("BCUDatabase", [Query = ""&SQL&""]),
    "Source DB", each "Beaumont", type text),
    CCSource = Table.AddColumn(
        Oracle.Database("RCCUDatabase", [Query = ""&SQL&""]),
    "Source DB", each "City Centre", type text),
    ABCUSource = Table.Combine({BBSource, CCSource}),

    #"Added Join Column" = Table.AddColumn(ABCUSource, "Join", each [Entity] &";"& [Source DB], type text)

in
    #"Added Join Column"
