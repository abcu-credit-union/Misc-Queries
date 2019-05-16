let
    SQL =
"SELECT
    GL_AcctBalHist.MonthYYYYMM ""Date"",
    FTI_AcctTitle.UserAcctNum ""GL Number"",
    FTI_Org.OrgShortName ""Branch"",
    GL_Acct.Description ""GL Name"",
    GL_Acct.FR2900Code ""FR2900 Code"",
    GL_AcctBalHist.YTDBal ""YTD Balance""
 FROM GL_ACCT
    LEFT OUTER JOIN FTI_AcctTitle
        ON GL_Acct.InstNum = FTI_AcctTitle.InstNum
            AND GL_Acct.GLAcctTitleNum = FTI_AcctTitle.GLAcctTitleNum
    LEFT OUTER JOIN FTI_Org
        ON GL_Acct.InstNum = FTI_Org.InstNum
            AND GL_Acct.OrgNum = FTI_Org.OrgNum
    LEFT OUTER JOIN GL_AcctBalHist
        ON GL_Acct.InstNum = GL_AcctBalHist.InstNum
            AND GL_Acct.GLAcctNum = GL_AcctBalHist.GLAcctNum
WHERE GL_AcctBalHist.MonthYYYYMM >= '201811'
    AND FTI_Org.OrgShortName <> 0
    AND GL_AcctBalHist.YTDBal <> 0
ORDER BY
    GL_AcctBalHist.MonthYYYYMM ASC,
    FTI_AcctTitle.UserAcctNum ASC",

    BBSource = Table.AddColumn(
        Sql.Database("10.207.18.10", "AB332PFTI", [Query = ""&SQL&""]),
    "Source DB", each 332, type number),
    CCSource = Table.AddColumn(
        Sql.Database("10.207.18.10", "AB242PFTI", [Query = ""&SQL&""]),
    "Source DB", each 242, type number),

    ABCUSource = Table.Combine({BBSource, CCSource}),

    #"Added Mappings" = Table.ExpandTableColumn(
        Table.NestedJoin(ABCUSource, {"FR2900 Code"}, GLMappings, {"FR2900 Code"}, "F&S Line", JoinKind.LeftOuter),
    "F&S Line", {"FSMS Line"}),

    #"Transformed Dates" = Table.ReorderColumns(
        Table.RenameColumns(
            Table.TransformColumns(
                Table.AddColumn(
                    Table.AddColumn(#"Added Mappings", "Month",
                        each fnMonth(Number.From(Text.Range([Date], 4))), type text),
                "Year", each Number.From(Text.Range([Date], 0, 4)), type number),
            {{"Date", each Number.From(Text.Range(_, 4)), type number}}),
        {"Date", "Month Index"}),
    {"Year", "Month", "Month Index", "FSMS Line", "FR2900 Code", "GL Number", "Branch", "GL Name", "YTD Balance", "Source DB"}),

    #"Sorted Results" = Table.Sort(#"Transformed Dates",
        {
            {"Year", Order.Ascending},
            {"Month Index", Order.Ascending},
            {"GL Number", Order.Ascending},
            {"Branch", Order.Ascending}
        })
in
    #"Sorted Results"
