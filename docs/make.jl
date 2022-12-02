using Pkg
Pkg.activate("docs")
Pkg.develop(PackageSpec(path=pwd()))
Pkg.instantiate()

using Documenter, BartIO

DocMeta.setdocmeta!(BartIO, :DocTestSetup, :(using BartIO); recursive=true)

makedocs(
    doctest = false,
    sitename = "BartIO.jl",
    modules  = [BartIO],
    authors="Jakob Asslaender <jakob.asslaender@nyumc.org> and Aurélien Trotier <a.trotier@gmail.com>",
    repo="https://github.com/MagneticResonanceImaging/BartIO.jl/blob/{commit}{path}#{line}",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/MagneticResonanceImaging/BartIO.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md"
    ],
)

deploydocs(;
    repo="github.com/MagneticResonanceImaging/BartIO.jl",
    push_preview = true,
)