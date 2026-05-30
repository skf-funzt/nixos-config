# ============================================================================
# Handy Audio Wrapper
#
# This file wraps the Handy speech-to-text application with proper audio
# library paths. ALSA library warnings about missing pipewire plugin are
# benign - handy will use PulseAudio which is available.
# ============================================================================
{
  pkgs,
  handy,
}:

let
  # Extract the handy package for the current system
  handyPackage = handy.packages.${pkgs.system}.handy;

  # ALSA plugins available in nixpkgs
  alsaPlugins = pkgs.alsa-plugins;

  # Core audio libraries
  audioLibs = with pkgs; [
    alsa-lib
    alsa-plugins
    pulseaudio
  ];

  # Build complete library path
  libPath = pkgs.lib.makeLibraryPath audioLibs;
in

pkgs.runCommand "handy-wrapped"
  {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  }
  (''
    mkdir -p $out/bin

    makeWrapper ${handyPackage}/bin/handy $out/bin/handy \
      --set ALSA_PLUGIN_DIR "${alsaPlugins}/lib/alsa-lib" \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --set ALSA_CARD default \
      --set ALSA_CTL_CARD default

    # Copy over other binaries and resources if they exist
    if [ -d ${handyPackage}/share ]; then
      mkdir -p $out/share
      cp -r ${handyPackage}/share/* $out/share/
    fi

    if [ -d ${handyPackage}/lib ]; then
      mkdir -p $out/lib
      cp -r ${handyPackage}/lib/* $out/lib/
    fi
  '')
