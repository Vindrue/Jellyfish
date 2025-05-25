function sem(σ, n)
	return σ/sqrt(n)
end

function zscore(x, μ, σ)
	#a::Tuple{Number, Number}, b::Tuple{Number, Number}
	#D = abs(a[1] - b[1])

	#Δ = sqrt(a[2]^2 + b[2]^2)

	return (x-μ)/σ
end

function propsem(vals::Vector, sem::Vector, func; var::SymPy.Sym=@sym(_x))
	if !checklenmatch([vals, sem])
		error("length mismatch between \"vals\" and \"sem\" arguments")
	end

	propsem = []
	for n in 1:length(vals)
		psem = diff(func(var))(vals[n]) * sem[n]

		append(propsem, psem)
	end

	return propsem
end

function properr(f; var=[], err, vals)

    if isempty(var)
        var = SymPy.free_symbols(f)
    end

    derives = []
    subsdict = []
    for i in 1:length(var)
        push!(derives, (dif(f, var[i])*err[i])^2)

        push!(subsdict, var[i] => vals[i])
    end

    return SymPy.subs(sqrt(sum(derives)), Dict(subsdict))
end

function chisq(o, e, Δ)
	chisq = 0
	for i in 1:length(o)
		chisq += ((o[i] - e[i])^2)/Δ[i]
	end
	
	return chisq
end
