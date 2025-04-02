function grad(func; var::Vector=reverse(collect(func.free_symbols)), order::Int=1) 
	#TODO: add support for vector fields

	grad = []
	for va in var
		push!(grad, dif(func, var=va, order=order))
	end

	return grad
end

#TODO: since xyz are "standard" variables maybe differentiate with respect to them as default for 2D/3D fields? (goes for curl as well)
function div(field::Vector, var::Vector)
	if !checklenmatch([field, var])
		error("length mismatch between \"field\" and \"var\" arguments")
	end

	div = 0
	for i in 1:length(field)
		div += diff(field[i], var=var[i])
	end

	return div
end

function curl(field::Vector, var::Vector)
	if !checklenmatch([field, var])
		error("length mismatch between \"field\" and \"var\" arguments")
	end

	if length(field) == 2
		return diff(field[2], var=var[1]) - diff(field[1], var=var[2])
	elseif length(field) == 3
		return [diff(field[3], var=var[2]) - diff(field[2], var=var[3]),
			diff(field[1], var=var[3]) - diff(field[3], var=var[1]),
			diff(field[2], var=var[1]) - diff(field[1], var=var[2])]
	else
		return error("curl() currently only supports 2D and 3D scalar fields")
	end
end
