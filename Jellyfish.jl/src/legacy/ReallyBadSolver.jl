function reallybadsolver(func, interval::Tuple{Number, Number}=(-1e10, 1e10), iterations=100)
	if checkfunc_R1(func) == false
		error("$(nameof(func)) is not a function in R¹")
	end

	x_min = interval[1]
	x_max = interval[2]

	x_mid = (x_max - x_min)/2

	for i in 1:iterations
		x_mid = x_min + (0.5 * (x_max - x_min))
		if func(x_mid) < 0
			x_min = x_mid
		else
			x_max = x_mid
		end
	end
	return x_mid
end
