include("parse.jl")

#Value Stuff

struct closV <: Value
    parms::Array
    body::exprC
    env::Env
end

struct numV <: Value
    val::Number
end

struct strV <: Value
    str::String
end

struct primV <: Value
    op::String
end

struct errorV <: Value
end

struct boolV <: Value
    val::Bool
end

#extends an environment
function extend_env(env, parms, vals)
    nenv = env.bindings
    for i in range(1, length(parms))
        prepend!(nenv, [Binding(parms[i], vals[i])])
    end
    return Env(nenv)
end

#looks up an id in an environment
function env_lookup(find, env)
    for binding in env.bindings
        if cmp(binding.name, find) == 0
            return binding.val
        end
    end
    error("TULI5: name not found in Environment")
end

#fucntion that handles all the two variable operations (primV's)
function binop(op, a1, a2)
    if cmp("+", op) == 0
        if typeof(a1) != numV || typeof(a2) != numV
            error("TULI5 invalid + call")
        end
        return numV(a1.val + a2.val)
    elseif cmp("-", op) == 0
        if typeof(a1) != numV || typeof(a2) != numV
            error("TULI5 invalid - call")
        end
        return numV(a1.val - a2.val)
    elseif cmp("*", op) == 0
        if typeof(a1) != numV || typeof(a2) != numV
            error("TULI5 invalid * call")
        end
        return numV(a1.val * a2.val)
    elseif cmp("/", op) == 0
        if typeof(a1) != numV || typeof(a2) != numV
            error("TULI5 invalid / call")
        end
        if a2.val == 0
            error("TULI5 division by 0")
        end
        return numV(a1.val / a2.val)
    elseif cmp("<=", op) == 0
        if typeof(a1) != numV || typeof(a2) != numV
            error("TULI5 invalid <= call")
        end
        return boolV(a1.val <= a2.val)
    elseif cmp("equal?", op) == 0
        return boolV(a1 == a2)
    end
end

#serializes values into strings
function serialize(Value)
    if typeof(Value) == numV
        return string(Value.val)
    elseif typeof(Value) == boolV
        if Value.val
            return "true"
        else
            return "false"
        end
    elseif typeof(Value) == strV
        return Value.str
    elseif typeof(Value) == closV
        return "<procedure>"
    elseif typeof(Value) == primV
        return "<primative>"
    else
        error("TULI5 unserializable value ", Value)
    end
end

#top interp function
function top_interp(expr)
    return serialize(interp(parse(expr), top_level_env))
end

#Interp function returns a value
function interp(exprC, env)
    if typeof(exprC) == numC
        return numV(exprC.val)
    elseif typeof(exprC) == strC
        return strV(exprC.str)
    elseif typeof(exprC) == ifC
        interped = interp(exprC.val, env)
        if typeof(interped) == boolV
            if interped.val
                return interp(exprC.then, env)
            else
                return interp(exprC.elsee, env)
            end
        else
            error("Invalid TULI5 if statement")
        end
    elseif typeof(exprC) == idC
        return env_lookup(exprC.id, env)
    elseif typeof(exprC) == lamC
        return closV(exprC.parms, exprC.body, env)
    elseif typeof(exprC) == appC
        interped = interp(exprC.fun, env)
        args = exprC.args
        if typeof(interped) == closV
            arg_vals = []
            for arg in args
                append!(arg_vals, [interp(arg, env)])
            end
            if length(interped.parms) == length(arg_vals)
                interp(interped.body, extend_env(interped.env, interped.parms, arg_vals))
            else
                error("number of TULI5 parameters and arguments do not match")
            end
        elseif typeof(interped) == primV
            if length(args) == 2
                binop(interped.op, interp(args[1], env), interp(args[2], env))
            else
                error("Invalid num of args for builtin TULI5 function")
            end
        elseif typeof(interped) == errorV
            if length(args) == 1
                error("TULI 5 User error ", serialize(args[1]))
            else
                error("Invalid num of args for error TULI5 function")
            end
        else
            error("not a TULI5 Function ", exprC)
        end
    end
end

top_level_env = Env(
    [
        Binding("+", primV("+")),
        Binding("-", primV("-")),
        Binding("*", primV("*")),
        Binding("/", primV("/")),
        Binding("<=", primV("<=")),
        Binding("equal?", primV("equal?")),
        Binding("true", boolV(true)),
        Binding("false", boolV(false)),
        Binding("error", errorV())
    ]
)

println(top_interp(4))
println(top_interp(["+", 3, 4]))
println(top_interp(["-", 3, 4]))
println(top_interp(["/", 3, 4]))
println(top_interp(["*", 3, 4]))
println(top_interp([["fn" ["x", "y"] ["*", "x", "y"]], [3, 4]]))