/*
Provides a list of all active members based on having a active, non-share account with a non-zero $ balance
*/
let

SQL =
"SELECT
    EFFDATE,
    PRODUCT,
    MJACCTTYPCD,
    CURRACCTSTATCD,
    ACCTNBR,
    TAXRPTFORPERSNBR,
    TAXRPTFORORGNBR,
    MONTHENDYN
FROM WH_ACCTCOMMON
WHERE
    EFFDATE = TRUNC(CURRENT_DATE - 1)
    AND CURRACCTSTATCD <> 'CLS'
    AND CURRMIACCTTYPCD NOT IN ('ECSM', 'ECSC')
    AND NOTEBAL <> 0",


    BBSource = Table.AddColumn(
        Oracle.Database("BCUDatabase", [Query = ""&SQL&""]),
    "Source DB", each "Beaumont", type text),
    CCSource = Table.AddColumn(
        Oracle.Database("RCCUDatabase", [Query = ""&SQL&""]),
    "Source DB", each "City Centre", type text),
    ABCUSource = Table.Combine({BBSource, CCSource}),

    #"Grouped Rows" = Table.Group(ABCUSource, {"EFFDATE", "TAXRPTFORPERSNBR", "TAXRPTFORORGNBR", "Source DB"},
        {{"Count", each Table.RowCount(_), type number}}),
    #"Renamed Columns" = Table.RenameColumns(#"Grouped Rows",
        {{"TAXRPTFORORGNBR", "Organizations"},
        {"TAXRPTFORPERSNBR", "Persons"}})
in
    #"Renamed Columns"
