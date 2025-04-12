
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Core
    python312Full
    julia
    
    # Basic build tools
    gcc
    gfortran
    
    # System libraries
    stdenv.cc.cc.lib
    xorg.libX11
    libGL
    
    # For potential GUI applications
    gtk3
    
    # Basic development tools
    pkg-config
  ];

  shellHook = ''
    # Create virtual environment if it doesn't exist
    if [ ! -d .venv ]; then
      python -m venv .venv
    fi
    source .venv/bin/activate

    # Ensure pip is up to date
    pip install --upgrade pip

    # Set JULIA_DEPOT_PATH to local directory
    export JULIA_DEPOT_PATH=$PWD/.julia

    # Basic LD_LIBRARY_PATH setup
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH

    echo "Python and Julia development environment ready!"
    echo "Python version: $(python --version)"
    echo "Julia version: $(julia --version)"
    echo ""
    echo "You can install Python packages using pip"
    echo "You can install Julia packages using Pkg.add() in Julia"
  '';

  # Basic library path preservation
  NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
  ];
  NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
}
