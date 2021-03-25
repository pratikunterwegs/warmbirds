# code to try reading shapefiles and use endemicr
using RCall

a = R"(rnorm(10))" # the r string macro

R"hist($a)" # hahaha this is great!