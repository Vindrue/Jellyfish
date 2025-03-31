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
