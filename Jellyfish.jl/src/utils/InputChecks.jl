function checkfunc_R1(func)
	@sym _x
	passed = true

	if isa(func(_x), SymPyCore.Sym{PyCall.PyObject})
		# hacky solution, but i can't imagine many actual functions being undefined for specifically
		# this number, actually this is retarded i'm deleting ℝ¹ checks until i figure out a good
		# solutionm,,,,,,,,,,,,
		try
			Float(func(43278))
		catch e
			passed = false
		end
	end

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
