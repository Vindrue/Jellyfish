function plot(data; constrain=false, xlims=(-4, 4), ylims=(), values=10000, yerr=[], save="", labels=[], xlabel="", ylabel="", xticks=([], []))
	aspect_ratio = :auto
	if constrain
		aspect_ratio = :equal
	end

	func,nonfunc = typesorter(data)

	#lambdify SymPy expressions (speed)
	for i in 1:length(func)
		if func[i] isa Sym
			func[i] = lambdify(func[i], collect(func[i].free_symbols))
		end
	end
	


	gr()

	#plot functions
	if !isempty(func)
		vals = preplotter(func; constrain, xlims, ylims, values, labels)

		ylims_min = []
		ylims_max = []
		for i in 1:length(vals)
			append!(ylims_min, vals[i][4][1])
			append!(ylims_max, vals[i][4][2])
		end
		ylims = (convert(Float64, minimum(ylims_min)), convert(Float64, maximum(ylims_max)))


		#create plot based on first function
		if xticks == ([], [])
			p = Plots.scatter(vals[1][1], vals[1][2], xlimits=xlims, ylimits=ylims, label=vals[1][7], markersize=1, markercolor=:red, markerstrokewidth=0, aspect_ratio=aspect_ratio, xlabel=xlabel, ylabel=ylabel, dpi=1000)
		else
			p = Plots.scatter(vals[1][1], vals[1][2], xlimits=xlims, ylimits=ylims, label=vals[1][7], markersize=1, markercolor=:red, markerstrokewidth=0, xlabel=xlabel, ylabel=ylabel, xticks=xticks, aspect_ratio=aspect_ratio, dpi=1000)
		end

		#add following functions to plot
		if length(vals) > 1
			for i in 2:length(vals)
				Plots.scatter!(p, vals[i][1], vals[i][2], label=vals[i][7], markersize=1, markerstrokewidth=0)
			end
		end

		if !isempty(nonfunc)
			for i in 1:length(nonfunc)
				Plots.scatter!(p, nonfunc[i][1], nonfunc[i][2])
			end
		end
	else
		if !isempty(yerr)
			p = Plots.scatter(nonfunc[1][1], nonfunc[1][2], yerr=yerr)
		else
			p = Plots.scatter(nonfunc[1][1], nonfunc[1][2], aspect_ratio=aspect_ratio, ms=0.5, color = :black)
		end
	end

	if length(nonfunc) > 1
		for i in 2:length(nonfunc)
			Plots.scatter!(p, nonfunc[i][1], nonfunc[i][2])
		end
	end

	if !isempty(save)
		Plots.savefig(p, save)

		return nothing
	else
		return p
	end
end

function typesorter(data)

	func = []
	nonfunc = []

	function validate_case3(element)
		return isa(element, Function) || 
        	isa(element, Sym) || 
        	(isa(element, Array) && length(element) == 2 && all(isa.(element, Array))) ||
		isa(element, Matrix) ||
		isa(element, PyObject)
	end

	#Case 1: data is of the shape f(x)
	if data isa Function || data isa Sym
		push!(func, data)
	
	#Case 2: data is of the shape [x,y]
	elseif isa(data, Array) && length(data) == 2 && all(v -> isa(v, Vector), data)
		push!(nonfunc, data)

	#Case 3: data is array of callables and/or [x,y]
	elseif all(validate_case3.(data))
		for element in data
			if isa(element, Function) || isa(element, Sym) || isa(element, PyObject)
        			push!(func, element)
        		elseif isa(element, Array) && length(element) == 2
            			push!(nonfunc, element)
			elseif element isa Matrix
				push!(nonfunc, collect(eachrow(data)))
        		end
    		end
	#Case 4: data is of the shape [x, y] but mangled by retarded Python type exports
	elseif data isa Matrix
		nonfunc = collect(eachrow(data))

	#Case 5: data is of the shape [[x1,y1], [x2,y2] ... [xn, yn]] but mangled by retarded Python type exports
	elseif ndims(data) == 3 && eltype(data) <: Number
		nonfunc = [[[data[i,j,k] for k in 1:size(data,3)] for j in 1:size(data,2)] for i in 1:size(data,1)]
	end

	return func,nonfunc
end

#big ass
function preplotter(func; constrain::Bool=false, xlims::Tuple=(-4, 4), ylims::Tuple=(), values::Int=2, labels::Array=[])	
	#define x as array from lower limit to upper limit with 10 000 values in between
	step = (xlims[2] - xlims[1])/values
	
	defylims = ylims

	defx = collect(xlims[1]:step:xlims[2])

	if !isa(func, Array)
		func = [func]
	end
	
	#print(func[1](3))

	outputs = []
	funcindex = 1
	for f in func
		x = copy(defx)
		y = []
		ylims = defylims
		#elementwise exection of func() on x[], appends to y[]
		#if func(x[n]) is undefined add n to badx
		index = 1
		badx = []
		for i in x
			#append!(y, f(i))
			try
				append!(y, f(i))
			catch e
				#print(e)
				append!(badx, index)
			finally
				#if y has an element that equals to either Inf or -Inf
				#remove element and append index to badx
				if !isempty(y) && y[end] == Inf || !isempty(y) && y[end] == -Inf
					append!(badx, index)
					deleteat!(y, length(y))
				end
			end
			index += 1
		end

		if isempty(y)
			println("No real values for func(x) or func() takes more than 1 argument")
			return
		end

		#remove x values that return undefined y values
		deleteat!(x, badx)

		#if no y limits given define y limits as min and max of x[]
		pwidth=40
		if isempty(ylims)
			ylims = (minimum(y),maximum(y))

			if constrain
				ylims=xlims
			end

		#if constrain=true and y limits given define width of plot
		elseif constrain
			pwidth=40*((xlims[2] - xlims[1]) / (ylims[2] - ylims[1]))
		end

		#if width is too large scale plot to a max width of 80
		pheight=20
		if pwidth > 80
			factor = pwidth / 80

			pwidth = pwidth / factor
			pheight = pheight / factor
		end
		
		pheight = round(Int, pheight)
		pwidth = round(Int, pwidth)
	
		#for symbolic expressions
		y = convert(Array{Float64,1}, y)
	
		#labels
		
		if !isempty(labels)
			name = labels[funcindex]
		else
			name = ""		
			if f isa PyObject
				println("true")
				name = String(Symbol(f))
				m = match(r"function\s+(\w+)\s+at", name)
				name = m.captures[1]
			else
				try
					name = String(Symbol(f))
	
					if length(name) > 20
						name = "y$funcindex"
					end
				catch
					name = "y$funcindex"
	
					#convert sympy expression to function, get name of function, profit?
				end
			end
		end
		push!(outputs, [copy(x), y, xlims, ylims, pheight, pwidth, name])
		funcindex += 1
	end
	return outputs
end
