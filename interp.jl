abstract type exprC end

mutable struct numC <: exprC
    val::Number
end

mutable struct strC <: exprC
    str::String
end

mutable struct idC <: exprC
    id::String
end

mutable struct lamC <: exprC
    parms::Array
    body::exprC
end

mutable struct ifC <: exprC
    val::exprC
    then::exprC
    elsee::exprC
end

mutable struct appC <: exprC
    fun::exprC
    arg::Array
end

function interp(exprC)
    if typeof(exprC) == numC
        return exprC.val
    elseif typeof(exprC) == strC
        return exprC.str
    end
end

interp(strC("NICKEFNFNFNFNFNFNF"))