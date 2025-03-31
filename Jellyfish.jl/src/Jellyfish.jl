module Jellyfish


# Dependencies

import Plots
import SymPy
import PyCall
import Unitful
import Richardson
import TaylorSeries
import PhysicalConstants.CODATA2022


# Math Constants

const e = Base.MathConstants.e
const γ = Base.MathConstants.γ
const GAMMA = γ


# Submodules

include("utils/MathUtils.jl")
include("utils/Consts.jl")
include("utils/InputChecks.jl")
export @sym, physconst

include("math/Calculus.jl")
include("math/VectorCalculus.jl")
include("math/NumericVectorCalculus.jl")
include("math/NumericMath.jl")
include("math/Statistics.jl")
export dif, int, tpoly, nlim, nsolve, ndiv, ncurl, sem, propsem, chisq, grad, div, curl

include("legacy/2DPlotting.jl")
include("legacy/PlotScalarField.jl")
include("legacy/ReallyBadSolver.jl")
export plot, plotscalarfield, reallybadsolver

end
