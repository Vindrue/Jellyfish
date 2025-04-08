using Jellyfish
using Test

@sym x,y,z

total = 4

@testset "Jellyfish.jl" begin
	println("Testing Calculus.jl [1/$total]")
	@test dif(x^2) == 2*x
	@test dif(y*x^2, x, order=2) == 2*y

	@test int(x) == (x^2)/2
	@test int(x, y, lims=(0,2), order=2) == 4*x

	@test tpoly(exp(x), x) == x+1
	@test tpoly(exp(x), x, order=2, point=1) == ((e*(x-1)^2)/2) + e*(x-1) + e


	println("Testing VectorCalculus.jl [2/$total]")
	@test grad(x*y, [x,y]) == [y,x]
	@test grad(y^2*x^2, [y,x], order=2) == [2*x^2, 2*y^2]
	
	@test divg([x^2, y^3, z^2], [x,y,z]) == 2*x + 3*y^2 + 2*z

	@test curl([x*y*z, x*y*z, x*y*z], [x,y,z]) == [-x*y + x*z, x*y-y*z, -x*z+y*z]


	println("Testing NumericMath.jl [3/$total]")
	f(x) = (2*x)/x
	@test nlim(f, 1) > 1.99
	@test nlim(f, 1) < 2.01
	function g(x)
		return 2*x
	end
	@test nlim(g(x), 1, -) > 1.99
	@test nlim(g(x), 1, -) < 2.01
	@test nlim(g(x), 1, +) > 1.99
	@test nlim(g(x), 1, +) < 2.01

	@test nsolve(x-1) > 0.99 && nsolve(x-1) < 1.01
	@test nsolve(x^2, iterations=1) == 0.5005 # yes this is far away from the actual solution,
				 		  # the function should adhere to expected newton-raphson behaviour nonetheless
	
	println("Testing Solvers.jl [4/$total]")
	@test solve(x-1)[x] == 1
	@test solve(x-1, x)[x] == 1
	@test solve((y+x-1, x-0.5))[x] == 0.5
	@test solve((y+x-1, x-0.5), (x,y))[y] == 0.5
	
end
