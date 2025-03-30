module Jellyfish

import Plots
import SymPy
import PyCall
import Unitful
import Richardson
import TaylorSeries
import PhysicalConstants.CODATA2022

#############
# CONSTANTS #
#############

e = Base.MathConstants.e
γ = Base.MathConstants.γ

function physconst(name::String)
	name = Symbol(name)
	
	try
		return Unitful.ustrip(getfield(CODATA2022, name))
	catch e
		if name == Symbol("c")
			return Unitful.ustrip(getfield(CODATA2022, c_0))
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
			return Unitful.ustrip(getfield(CODATA2022, α))
		end
		if name == Symbol("K_J")
			return 483597.8484e9
		end
		if name == Symbol("ϕ_0") || name == Symbol("Phi_0")
			return 2.067833848e-15
		end
		if name == Symbol("R_oo")
			return Unitful.ustrip(getfield(CODATA2022, R_∞))
		end
		if name == Symbol("R_K")
			return 25812.80745
		end
	end

	error("constant not found")
end

######################
# DEPENDENCY EXPORTS #
######################

macro sym(symbol)
    if symbol isa Expr && symbol.head == :tuple
        #handle tuple case
        symbols = [string(s) for s in symbol.args]
        return quote
            $(Expr(:tuple, [esc(s) for s in symbol.args]...)) = SymPy.symbols($(join(symbols, ", ")))
        end
    else
        #handle single symbol case
        return quote
            $(esc(symbol)) = SymPy.symbols($(string(symbol)))
        end
    end
end
export @sym

############
# CALCULUS #
############

function colsym(func, sym)
	if String(Symbol(sym)) == "_x"
		#if the input is a symbolic expression collect symbols
		syms = collect(func.free_symbols)
		if length(syms) == 1
			sym = syms[1]
		else
			#TODO: throw proper error
			return "multi-variable expression, specify a variable in your function"
		end
	end

	return sym
end

function grad(func; var::Vector=collect(func.free_symbols), order::Int=1) 
	#TODO: add support for vector fields

	grad = []
	for va in var
		push!(grad, diff(func, var=va, order=order))
	end

	return grad
end

#TODO: since xyz are "standard" variables maybe differentiate with respect to them as default for 2D/3D fields? (goes for curl as well)
function div(field::Vector, var::Vector)
	div = 0
	for i in 1:length(field)
		div += diff(field[i], var=var[i])
	end

	return div
end

function curl(field::Vector, var::Vector)
	if length(field) == 2
		return diff(field[2], var=var[1]) - diff(field[1], var=var[2])
	elseif length(field) == 3
		return [diff(field[3], var=var[2]) - diff(field[2], var=var[3]),
			diff(field[1], var=var[3]) - diff(field[3], var=var[1]),
			diff(field[2], var=var[1]) - diff(field[1], var=var[2])]
	else
		return "bruh mismatch"
	end


end

function diff(func; var::SymPy.Sym=@sym(_x), order::Int=1)	
	#if symbol is not specified
	var = colsym(func, var)

	#differentiate symbolic expression with SymPy.diff
	derivative = func	
	for i in 1:order
		derivative = SymPy.diff(derivative, var)
	end

	return derivative
end

function int(func; var::SymPy.Sym=@sym(_x), lims::Tuple{Any, Any}=(nothing,nothing), order::Int=1)
	if isempty(lims)
		var = colsym(func, var)
		
		expr = func
		for i in 1:order
			expr = SymPy.integrate(expr, var)
		end

		return expr
	end

	var = colsym(func, var)

	expr = func
	for i in 1:order
		expr = SymPy.integrate(expr, (var, lims[1], lims[2]))
	end

	return expr
end

TaylorSeries.displayBigO(false)
function tpoly(func, var::SymPy.Sym; order::Int=1, point::Number=0)
	#if native Julia function use TaylorSeries package
	if func isa Function
		poly = 0

		return TaylorSeries.taylor_expand(func, point, order=order)
	end

	#collect variables in expression
	fs = collect(func.free_symbols)

	#put them into tuples, and into a list(for .subs())
	fslist = []
	for i in 1:length(fs)
		push!(fslist, (fs[i], fs[i]))
	end

	#replace variable that gets evaluated in the taylor polynomial with point
	varindex = (findall(x -> x == (var, var), fslist))[1]
	fslist[varindex] = (var, point)

	#taylor polynomial calc (super epic)
	poly = 0
	for n in 0:order
		poly = poly + ((SymPy.sympy.Derivative(func, var, n)).subs(fslist).doit()/factorial(n)) * (var-point)^n
	end

	return poly
end
export tpoly

#################
# DISCRETE MATH #
#################

function nlim(func, dest::Number, dir::Union{typeof(+), typeof(-)}=+)
	if checkfunc_R1(func) == false
		error("$(nameof(func)) is not a function in R¹")
	end

	#use richardson extrapolation to find limits
	res = Richardson.extrapolate(dir(0,0.0001), x0=dest, breaktol=Inf, maxeval=3) do x
		func(x)
	end

	#TODO: fix if statement returning wrong vals
	if res[1] > 1e10
		println("Result very large (may be infinite)")
		return res[1]
	elseif res[1] < -1e10
		println("Result very small (may be -infinite)")
		return res[1]
	else
		return res[1]
	end
end
export nlim

function nsolve(func, estimate::Number=0, iterations::Number=10)
	root = estimate
	for n in 1:iterations
		# TODO: can be optimized by moving the try-catch block outside of the for loop
		# actually passing differences could be their own little system
		try
			root = root - func(root)/diff(func)(root)
		catch e
			root = root - func(root)/diff(func)
		end
	end
	return root
end
export nsolve

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
export reallybadsolver

function ndiv(field::Tuple{Matrix{Float64}, Matrix{Float64}})
    u, v = field
    
    # get dimensions of field
    rows, cols = size(u)
    
    # initialize divergence matrix with zeros
    div = zeros(rows-1, cols-1)
    
    # assume uniform grid spacing of 1
    Δx = 1.0
    Δy = 1.0
    
    # compute divergence using finite differences
    for i in 1:rows-1
        for j in 1:cols-1
            # partial derivative with respect to x (du/dx)
            du_dx = (u[i+1,j] - u[i,j]) / Δx
            
            # partial derivative with respect to y (dv/dy)
            dv_dy = (v[i,j+1] - v[i,j]) / Δy
            
            div[i,j] = du_dx + dv_dy
        end
    end
    
    return div
end

function ncurl(field::Tuple{Matrix{Float64}, Matrix{Float64}})
    u, v = field
    
    # get dimensions of field
    rows, cols = size(u)
    
    # initialize divergence matrix with zeros
    div = zeros(rows-1, cols-1)
    
    # assume uniform grid spacing of 1
    Δx = 1.0
    Δy = 1.0
    
    # compute divergence using finite differences
    for i in 1:rows-1
        for j in 1:cols-1
            # partial derivative with respect to x (du/dx)
            du_dx = (u[i+1,j] - u[i,j]) / Δx
            
            # partial derivative with respect to y (dv/dy)
            dv_dy = (v[i,j+1] - v[i,j]) / Δy
            
            div[i,j] = du_dx - dv_dy
        end
    end
    
    return div
end

##################
# ERROR HANDLING #
##################

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

##############
# STATISTICS #
##############

function sem(σ, n)
	return σ/sqrt(n)
end
export sem

function zscore(a::Tuple{Number, Number}, b::Tuple{Number, Number})
	D = abs(a[1] - b[1])

	Δ = sqrt(a[2]^2 + b[2]^2)

	return D/Δ
end
export zscore

function propsem(vals::Vector{Number}, sem::Vector{Number}, func, var::SymPy.Sym=@sym(_x))
	if !checklenmatch([vals, sem])
		error("length mismatch between \"vals\" and \"sem\" arguments")
	end

	propsem = []
	for n in 1:length(vals)
		psem = diff(func(var))(vals[n]) * sem[n]

		append(propsem, psem)
	end

	return propsem
end
export propsem

function chisq(x::Array, y::Array, ysem::Vector, model)
	if !checklenmatch([x, y])
		error("length mismatch between \"x\" and \"y\" arguments")
	end

	chisq = 0
	for i in 1:length(x)
		chisq += ((y[i] - model(x[i]))^2)/(ysem[i]^2)
	end
	
	return chisq
end
export chisq

#################
# VISUALIZATION #
#################

#TODO: add labels (perhaps a common function for grabbing names to be used in the visualization functions?)
function plotscalarfield(func; var::Vector=collect(func.free_symbols), lims::Vector=[(-4,4), (-4,4)], vals::Int=10000, clim=(Nothing, Nothing))
	valspervar = Int(round(sqrt(vals)))
	vx = collect(range(lims[1][1], lims[1][2], valspervar))
	vy = collect(range(lims[2][1], lims[2][2], valspervar))

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


























#TODO: this entire section deserves a rewrite, too bad i'm lazy!

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

end
