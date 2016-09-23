if exists("b:current_syntax")
  finish
endif

syntax keyword lumbType Num Sym Str Bool Date Time
highlight link lumbType Type

syntax match lumbComment "\v#.*$"
highlight link lumbComment Comment

syntax match lumbOperator "\v/"
syntax match lumbOperator "\v\="
syntax match lumbOperator "\v\?"
syntax match lumbOperator "\v\.\.\."
syntax match lumbOperator "\v\.\."
highlight link lumbOperator Operator

syntax region lumbString oneline start=/\v"/ skip=/\v\\./ end=/\v"/
syntax region lumbString oneline start=/\v'/ skip=/\v\\./ end=/\v'/
syntax match lumbString "\v\|.*$"
syntax match lumbSymbol "\v:\S+"
highlight link lumbString String
highlight link lumbSymbol String

syntax match lumbStringComment "\v^\s.*$"
highlight link lumbStringComment Comment

syntax keyword lumbBoolean true yes false no
highlight link lumbBoolean Boolean

syntax match lumbNumber /\v(\$|<)=[+-]=[0-9]([_,]=\d)*(\.[0-9]+)=([eE][0-9]+)=([a-z]+)=(\%|>)/
highlight link lumbNumber Number

syntax match lumbDate /\v(\(|<)\d{4}-\d{2}-\d{2}(\)|>)/
highlight link lumbDate Statement

syntax match lumbIdentifier /\v<[a-z][a-z0-9\-_]*>/
highlight link lumbIdentifier Identifier

let b:current_syntax = "lumb"

