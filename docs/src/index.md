# BartIO documentation


## Calling BART functions

### Requirements
 - [BART](https://github.com/mrirecon/bart) -> compiled
 - [bartpy](https://github.com/mrirecon/bartpy) -> does not required to be installed

In order to call bart, the new python wrapper needs to be install in the pycall environment with :
```@docs
initBart(path2bart::String,path2bartpy::String)
```

### Alternatively
BART can be called from the terminal :
```julia
run(`bart version`)
```
or with the standard wrapper available in the bart/python
```julia
py"""
import sys
sys.path.insert(0, "/Users/aurelien/Documents/SOFTWARE/bart/python/")
"""

bart = pyimport("bart")["bart"]

bart(0,"version")
img = bart(1,"phantom -x64")
```

## IO to BART files

If you want to call the bart with the terminal you need to write/read the BART files using  :
- readcfl
- writecfl

```@docs
readcfl(filename::String)
```

```@docs
writecfl(filename::String,dataCfl::Array{ComplexF32})
```