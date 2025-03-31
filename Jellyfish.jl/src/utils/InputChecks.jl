function checkfunc_R1(func)
	@sym _x
	passed = true
	try
		func(_x)
	catch e
		passed = false

		#error("$(nameof(func)) is not a function in R¹")
	end

	return passed	
end

function checklenmatch(arr)
	lengths = []
	for array in arr
		append!(lengths, length(array))
	end

	std = lengths[1]
	for length in lengths
		if std != length
			return false
		end
	end

	return true
end
