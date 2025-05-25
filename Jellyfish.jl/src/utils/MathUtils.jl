macro sym(symbol)
    if symbol isa Expr && symbol.head == :tuple
        # handle tuple
        symbols = [string(s) for s in symbol.args]
        return quote
            $(Expr(:tuple, [esc(s) for s in symbol.args]...)) = SymPy.symbols($(join(symbols, ", ")))
        end
    else
        # handle single symbol
        return quote
            $(esc(symbol)) = SymPy.symbols($(string(symbol)))
        end
    end
end

function colsym(func, sym)
	if String(Symbol(sym)) == "_x"
		# if the input is a symbolic expression collect symbols
		syms = collect(func.free_symbols)
		if length(syms) == 1
			sym = syms[1]
		else
			error("multi-variable expression, specify a variable in your function")
		end
	end

	return sym
end

function tex(expr)
	return SymPy.latex(expr)
end
