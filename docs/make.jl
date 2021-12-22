using Documenter, BartIO

makedocs(
         sitename = "BartIO.jl",
         modules  = [BartIO],
         pages=[
                "Home" => "index.md"
               ])

deploydocs(;
               repo="github.com/aTrotier/BartIO.jl",
           )               