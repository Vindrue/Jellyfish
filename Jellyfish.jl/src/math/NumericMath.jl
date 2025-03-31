function nlim(func, dest::Number, dir::Union{typeof(+), typeof(-)}=+)
	if checkfunc_R1(func) == false
		error("$(nameof(func)) is not a function in R¹")
	end

	#use richardson extrapolation to find limits
	res = Richardson.extrapolate(dir(0,0.0001), x0=dest, breaktol=Inf, maxeval=3) do x
		func(x)
	end

	#TODO: give a warning when Richardson.extrapolate gives errors
	return res[1]
end

function nsolve(func, estimate::Number=0, iterations::Number=10)
	root = estimate
	for n in 1:iterations
		# TODO: can be optimized by moving the try-catch block outside of the for loop
		# actually passing differences could be their own little system
		try
			root = root - func(root)/diff(func)(root)
		catch e
			root = root - func(root)/diff(func)
		end
	end
	return root
end
