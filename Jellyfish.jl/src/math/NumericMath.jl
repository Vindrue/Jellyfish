function nlim(func, dest::Number, dir::Union{typeof(+), typeof(-)}=+)

	#use richardson extrapolation to find limits
	res = Richardson.extrapolate(dir(0,0.0001), x0=dest, breaktol=Inf, maxeval=3) do x
		func(x)
	end

	#TODO: give a warning when Richardson.extrapolate gives errors
	return res[1]
end

function nsolve(func; estimate::Number=1.001, iterations::Number=50)
	root = estimate
	for n in 1:iterations
		# TODO: can be optimized by moving the try-catch block outside of the for loop
		# actually passing differences could be their own little system
		try
			root = root - func(root)/dif(func)(root)
		catch e
			root = root - func(root)/dif(func)
		end
	end
	return root
end
