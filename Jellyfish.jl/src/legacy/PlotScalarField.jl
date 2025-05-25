function plotscalarfield(func; var::Vector=collect(func.free_symbols), lims::Vector=[(-4,4), (-4,4)], vals::Int=1000, clim=(Nothing, Nothing))
	valspervar = Int(round(sqrt(vals)))
	vx = collect(range(lims[1][1] + _ε, lims[1][2] + _ε, valspervar))
	vy = collect(range(lims[2][1] + _ε, lims[2][2] + _ε, valspervar))

	vf = []
	for x in vx
		for y in vy
			vf = push!(vf, func(x, y))
		end
	end

	if clim == (Nothing,Nothing)
		clim = (Float64(minimum(vf)), Float64(maximum(vf)))
	end

	Plots.contourf(vx, vy, vf, clim=clim)
end

function plotvectorfield(vec; var::Vector=collect(func.free_symbols), lims::Vector=[(-4,4), (-4,4)], vals::Int=1000, clim=(Nothing, Nothing))


	valspervar = Int(round(sqrt(vals)))

	vx = collect(range(lims[1][1] + _ε, lims[1][2] + _ε, valspervar))
	vy = collect(range(lims[2][1] + _ε, lims[2][2] + _ε, valspervar))

	vf = []
	for x in vx
		for y in vy
			vf = push!(vf, vec(x, y))
		end
	end



	Plots.plot

