#ExprC Stuff
abstract type exprC end
abstract type Value end

#Environment Stuff
struct Binding
    name::String
    val::Value
end

struct Env
    bindings::Array
end

struct numC <: exprC
    val::Number
end

struct strC <: exprC
    str::String
end

struct idC <: exprC
    id::String
end

struct lamC <: exprC
    parms::Array
    body::exprC
end

struct ifC <: exprC
    val::exprC
    then::exprC
    elsee::exprC
end

struct appC <: exprC
    fun::exprC
    args::Array
end

function valid_id(id)
    if id == "if"
        false
    elseif id == "let"
        false
    elseif id == "in"
        false
    elseif id == "fn"
        false
    else
        true
    end
end

#checks for no duplicates in function variables
function check_duplicates(parms)
    for i in range(1, length(parms))
        for j in range(i + 1, length(parms))
            if parms[i] == parms[j]
                return true
            end
        end
    end
    return false
end

#checks to sure all parameters are strings
function check_all_strings(parms)
    if !isa(parms, Array)
        return false
    end
    for s in parms
        if isa(s, String)
            return false
        end
    end
    return true
end

function parse_array(list)
    tr = []
    for l in list
        append!(tr, parse(l))
    end
    return tr
end

#input is in format ['var', ['z','=',14], ['+', 'z', 'z']]
#parses concrete syntax into an exprC
function parse(input)
    if isa(input, Number)
        return numC(input)
    elseif length(input) == 1 && isa(input, Array) && isa(input[1], Number)
        return numC(input[1])
    elseif typeof(input) == String
        if valid_id(input)
            return idC(input)
        else
            error("Invalid TULI5 id ", input, " in parse")
        end
    elseif length(input) == 4 && input[1] == "if"
        return ifC(parse(input[2]), parse(input[3]), parse(input[4]))
    elseif length(input) == 3 && input[1] == "fn" && check_all_strings(input[2])
        if check_duplicates(input[2])
            error("TULI5 duplicate parms parse")
        else
            print("here")
            return lamC(parse_array(input[2]), parse[input[3]])
        end
    elseif length(input) >= 2
        for i in range(2, length(input))
            append!(args, [parse(input[i])])
        end
        return appC(parse(input[1]), args)
    else 
        error("Invlid TULI5 expression reading ", input, " in parse")
    end
end

parse(["fn", ["x"], ["+", "x", 3]])