let
    SQL =
"SELECT
    (CASE WHEN WH_ACCTCOMMON.TAXRPTFORPERSNBR IS NOT NULL THEN
        'P' || WH_ACCTCOMMON.TAXRPTFORPERSNBR
        ELSE 'O' || WH_ACCTCOMMON.TAXRPTFORORGNBR END) ""Entity""
FROM WH_ACCTCOMMON
WHERE
    EFFDATE = TRUNC(CURRENT_DATE - 1)
    AND CURRACCTSTATCD NOT IN ('CLS', 'CO', 'DORM')
    AND CURRMIACCTTYPCD NOT IN ('ECSM', 'ECSC')
    AND NOTEBAL <> 0",

     BBSource = Table.AddColumn(
        Oracle.Database("BCUDatabase", [Query = ""&SQL&""]),
    "Source DB", each "Beaumont", type text),
    CCSource = Table.AddColumn(
        Oracle.Database("RCCUDatabase", [Query = ""&SQL&""]),
    "Source DB", each "City Centre", type text),
    ABCUSource = Table.Combine({BBSource, CCSource}),

    #"Grouped Rows" = Table.Group(ABCUSource, {"Entity", "Source DB", "Branch"},
        {{"Number of Products", each Table.RowCount(_), type number}}),

    #"Added Join Column" = Table.AddColumn(#"Grouped Rows", "Join",
        each [Entity] &";"& [Source DB], type text)


in
    #"Added Join Column"
