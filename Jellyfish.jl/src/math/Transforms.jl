# Unfinished symbolic fourier transform,,,,

#function fourier(func)
#	# TODO: add domain support for @sym
#	SymPy.@syms _t,_ω
#
#	# compute fourier antiderivative
#	antideriv = int(func * e^(-im*_t*_ω))
#
#	# get expression that covers the real plane of ω,t with measure 0
#	for i in 1:length(antideriv.args)
#		if antideriv.args[i].args[2] == true
#			antideriv = antideriv.args[i].args[1]
#			break
#		end
#	end
#
#	
#
#	return antideriv
#end
