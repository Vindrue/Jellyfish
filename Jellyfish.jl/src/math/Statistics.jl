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

function chisq(x::Array, y::Array, ysem::Vector, model)
	if !checklenmatch([x, y])
		error("length mismatch between \"x\" and \"y\" arguments")
	end

	chisq = 0
	for i in 1:length(x)
		chisq += ((y[i] - model(x[i]))^2)/(ysem[i]^2)
	end
	
	return chisq
end
