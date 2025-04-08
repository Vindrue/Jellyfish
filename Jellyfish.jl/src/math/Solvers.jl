function solve(eq, var=(); domain=SymPy.sympy.Reals())
	# TODO: add error catching mechanisms for mismatches between eq and var when both specified
	
	# i'm genuinely starting to regret using SymPy for this, there are numerous issues here, domains aren't even
	# working with most sympy solvers (including nonlinsolve()), domains should be ignored for now
	# also trig and transcendental equations are wonky rn (can solve, but output is hard to read)


	# if no solution variables provided
	if isempty(var)
		
		colvars = []
		for equation in eq
			append!(colvars, collect(equation.free_symbols))
		end
		var = Tuple(reverse(unique(colvars)))

		# if no solution variable & system of equations
		if isa(eq, Tuple)

			if length(eq) >= length(var)
				#pass1_solution = SymPy.nonlinsolve(eq, var, PyCall.convert(PyCall.PyObject, domain))
				pass1_solution = SymPy.solve(eq, var)
			else
				error("System of $(len(eq)) equations provided,
				      yet not enough equations to solve for all $(len(var)) variables,
				      specify solution variables with the var=[] method")	
			end
		# if no solution variable & single equation
		else
			var = collect(eq.free_symbols)[1]
			if length(var) <= 1
				#pass1_solution = SymPy.nonlinsolve((eq,), (var,), PyCall.convert(PyCall.PyObject, domain))
				pass1_solution = SymPy.solve((eq,), (var,))
			else
				error("More than 1 variable found in eq, specify solution variables with the var=[] method")
			end
		end
	# if solution variables specified
	else
		# if solution variables specified and system of equations
		if isa(eq, Tuple) && isa(var, Tuple)
			if length(eq) >= length(var)
				#pass1_solution = SymPy.nonlinsolve(eq, var, PyCall.convert(PyCall.PyObject, domain))
				pass1_solution = SymPy.solve(eq, var)
			else
				error("System of $(len(eq)) equations provided,
				      yet not enough equations to solve for all $(len(var)) variables specified.")	
			end
		# if solution variables specified and single equation
		else
			if length(var) <= 1
				#pass1_solution = SymPy.nonlinsolve((eq,), (var,), PyCall.convert(PyCall.PyObject, domain))
				pass1_solution = SymPy.solve((eq,), (var,))
			else
				error("More than 1 variable provided.")
			end
		end
	end

	# ok so this thing breaks tremendously, i'm tired of dealing with segfaults from Python's garbage collector
	# the entire check complex solutions thing might be revisited at some point in the future

	#defaultdomain = false
	#if PyCall.convert(PyCall.PyObject, domain) == PyCall.convert(PyCall.PyObject, SymPy.sympy.Reals())
	#	defaultdomain = true
	#end

	# checking for solutions in ℂ if no solutions in ℝ
	# yes this checks if the domain is directly sympy.Reals() and not ℝ/REALS, this is intentional as this procedure
	# is meant to be used when the domain is not specified (if i specify only real solutions i do not want warnings)
	
	#if defaultdomain && pass1_solution == SymPy.sympy.EmptySet() && SOLVEWARNINGS &&
	#	SymPy.nonlinsolve(eq, var, SymPy.sympy.Complexes()) != SymPy.sympy.EmptySet()
	#	
	#	print("No solutions in ℝ exist, solutions in ℂ exist,
	#		use domain=ℂ OR domain=COMPLEXES to find them.")
	#	
	#	return pass1_solution
	#end

	return pass1_solution
end
