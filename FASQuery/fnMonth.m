(m) =>
let
    months =
    {
        {m = 1, "January"},
        {m = 2, "February"},
        {m = 3, "March"},
        {m = 4, "April"},
        {m = 5, "May"},
        {m = 6, "June"},
        {m = 7, "July"},
        {m = 8, "August"},
        {m = 9, "September"},
        {m = 10, "October"},
        {m = 11, "November"},
        {m = 12, "December"}
    },

    result = List.First(List.Select(months, each _{0} = true)){1}
in
    result
