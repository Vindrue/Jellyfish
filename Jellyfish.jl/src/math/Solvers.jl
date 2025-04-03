function solve(eq, var::Vector=reverse(collect(eq.free_symbols)), domain=ℝ)
	
	if domain == ℝ
		ℝ_solution = solveset(eq, var, domain)

		if ℝ_solution == ∅ && SOLVEWARNINGS
			if solveset(eq, var, ℂ) != ∅
				print("No solutions in ℝ exist, solutions in ℂ exist, use domain=ℂ OR domain=COMPLEXES to find them.")
				return ℝ_solution
			end
		return ℝ_solution
		end
	end
	
	return solveset(eq, var, domain)
end
