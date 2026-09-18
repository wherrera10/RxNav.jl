using Documenter, RxNav

DocMeta.setdocmeta!(RxNav, :DocTestSetup, :(using RxNav); recursive=true)

makedocs(;
    modules=[RxNav],
    authors="William Herrera",
    sitename="RxNav.jl Documentation",
    repo="https://github.com/wherrera10/RxNav.jl/blob/{commit}{path}#{line}",
    format=Documenter.HTML(;
        canonical="https://wherrera10.github.io/RxNav.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        # Add future pages here, e.g., "API Reference" => "api.md"
    ],
)

deploydocs(;
    repo="github.com/wherrera10/RxNav.jl.git",
    devbranch="main",
)

  
