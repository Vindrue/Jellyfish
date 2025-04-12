function dif(func, var::SymPy.Sym=@sym(_x); order::Int=1)	
	#if symbol is not specified
	var = colsym(func, var)

	#differentiate symbolic expression with SymPy.diff
	derivative = func	
	for i in 1:order
		derivative = SymPy.diff(derivative, var)
	end

	return derivative
end

function int(func, var::SymPy.Sym=@sym(_x); lims::Tuple{Any, Any}=(nothing,nothing), order::Int=1)
	if isempty(lims)
		var = colsym(func, var)
		
		expr = func
		for i in 1:order
			expr = SymPy.integrate(expr, var)
		end

		return expr
	end

	var = colsym(func, var)

	expr = func
	for i in 1:order
		expr = SymPy.integrate(expr, (var, lims[1], lims[2]))
	end

	return expr
end

TaylorSeries.displayBigO(false)
function tpoly(func, var = false; order::Int=1, point::Number=0)

	# if native Julia function use TaylorSeries package
	if func isa Function
		if isa(var, Bool) && var == false # TODO: decide on some kind of consistent system for detecting
						  # defaults (Python gc my worst enemy)
			@sym _x
		end
		poly = 0

		tpoly = TaylorSeries.taylor_expand(func, point, order=order)
		tpoly = tpoly(_x)
		return tpoly
	end

	if isa(var, Bool) && var == false
		var = collect(func.free_symbols)[1]
	end

	# collect variables in expression
	fs = collect(func.free_symbols)

	# put them into tuples, and into a list(for .subs())
	fslist = []
	for i in 1:length(fs)
		push!(fslist, (fs[i], fs[i]))
	end

	# replace variable that gets evaluated in the taylor polynomial with point
	varindex = (findall(x -> x == (var, var), fslist))[1]
	fslist[varindex] = (var, point)

	# taylor polynomial calc (super epic)
	poly = 0
	for n in 0:order
		poly = poly + ((SymPy.sympy.Derivative(func, var, n)).subs(fslist).doit()/factorial(n)) * (var-point)^n
	end

	return poly
end
