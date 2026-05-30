# ============================================================================
# VS Code Wrapper Configuration
#
# This file creates a wrapped version of Visual Studio Code that includes
# additional shared libraries required by certain extensions, particularly
# the Microsoft Speech extension (ms-vscode.vscode-speech).
#
# PROBLEM SOLVED:
# The speech extension fails to load with error:
#   "libstdc++.so.6: cannot open shared object file: No such file or directory"
#   "libuuid.so.1: cannot open shared object file: No such file or directory"
#
# SOLUTION:
# We use symlinkJoin to create a new derivation that wraps VS Code's binary
# with the necessary library paths set via LD_LIBRARY_PATH.
#
# LIBRARIES INCLUDED:
#   - libstdc++.so.6 (from gcc's stdenv.cc.cc.lib)
#   - libuuid.so.1 (from libuuid package)
#
# USAGE:
# Import this file in home.nix and add the result to home.packages
# ============================================================================
{
  pkgs,
  pkgs-unstable,
  ...
}:
pkgs.symlinkJoin {
  name = "vscode";
  paths = [pkgs-unstable.vscode];
  nativeBuildInputs = [pkgs.makeWrapper];
  postBuild = ''
    # Wrap the VS Code binary to include additional library paths
    wrapProgram $out/bin/code \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib # Provides libstdc++.so.6 (C++ standard library)
      pkgs.libuuid # Provides libuuid.so.1 (UUID generation library)
    ]}
  '';
}
