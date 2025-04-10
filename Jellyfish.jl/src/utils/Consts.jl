function physconst(name::String)
	name = Symbol(name)
	
	try
		return Unitful.ustrip(getfield(CODATA2022, name))
	catch e
		if name == Symbol("c")
			return Unitful.ustrip(getfield(CODATA2022, Symbol("c_0")))
		end
		if name == Symbol("G_0")
			return 7.7480917299e-5
		end
		if name == Symbol("eV")
			return 1.602176634e-19
		end
		if name == Symbol("F")
			return 96485.33212
		end
		if name == Symbol("alpha")
			return Unitful.ustrip(getfield(CODATA2022, Symbol("α")))
		end
		if name == Symbol("K_J")
			return 483597.8484e9
		end
		if name == Symbol("ϕ_0") || name == Symbol("Phi_0")
			return 2.067833848e-15
		end
		if name == Symbol("R_oo")
			return Unitful.ustrip(getfield(CODATA2022, Symbol("R_∞")))
		end
		if name == Symbol("R_K")
			return 25812.80745
		end
	end

	error("constant not found")
end
