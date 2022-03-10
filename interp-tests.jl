using Test

include("interp.jl")

@test interp(numC(5), top_level_env) == numV(5)
@test interp(numC(0), top_level_env) == numV(0)

@test interp(ifC(idC("true"), numC(-1), numC(1)), top_level_env) == numV(-1)
@test interp(ifC(idC("false"), numC(-1), numC(1)), top_level_env) == numV(1)
@test_throws ErrorException("Invalid TULI5 if statement") interp(ifC(numC(324), numC(-1), numC(1)), top_level_env)

@test interp(appC(idC("<="), [numC(3), numC(2)]), top_level_env) == boolV(false)
@test interp(appC(idC("<="), [numC(3), numC(3)]), top_level_env) == boolV(true)

@test interp(appC(idC("+"), [numC(3), numC(5)]), top_level_env) == numV(8)
@test interp(appC(idC("-"), [numC(15), numC(4.5)]), top_level_env) == numV(10.5)
@test interp(appC(idC("*"), [numC(3), numC(31)]), top_level_env) == numV(93)
@test interp(appC(idC("/"), [numC(10), numC(5)]), top_level_env) == numV(2.0)
@test interp(appC(idC("equal?"), [numC(10), numC(5)]), top_level_env) == boolV(false)
@test interp(appC(idC("equal?"), [numC(10), numC(10)]), top_level_env) == boolV(true)

@test_throws ErrorException("TULI5 invalid + call") interp(appC(idC("+"), [boolV(true), numC(5)]), top_level_env) 
@test_throws ErrorException("TULI5 invalid - call") interp(appC(idC("-"), [boolV(true), numC(5)]), top_level_env) 
@test_throws ErrorException("TULI5 invalid * call") interp(appC(idC("*"), [boolV(true), numC(5)]), top_level_env)
@test_throws ErrorException("TULI5 invalid <= call") interp(appC(idC("<="), [boolV(true), numC(5)]), top_level_env) 
@test_throws ErrorException("TULI5 invalid / call") interp(appC(idC("/"), [boolV(true), numC(5)]), top_level_env)
@test_throws ErrorException("TULI5 division by 0") interp(appC(idC("/"), [numC(6), numC(0)]), top_level_env)

@test interp(appC(lamC(["a", "b"], appC(idC("+"), [idC("a"), idC("b")])), [numC(3), numC(7)]), top_level_env) == numV(10)
@test interp(appC(lamC(["a", "b"], appC(idC("a"), [idC("b")])), [lamC(["x"], appC(idC("*"), [idC("x"), idC("x")])), numC(10)]), top_level_env) == numV(100)


