function dot(v,u)
	return LinearAlgebra.dot(v,u)
end


function cross(v,u)
	try
		return LinearAlgebra.cross(v,u)
	catch e
		if length(v)==2 && length(u)==2
			push!(v, 0); push!(u, 0)

			return LinearAlgebra.cross(v,u)
		else
			error("cross() is only defined for 2 2D or 3D vectors")
		end
	end
end
