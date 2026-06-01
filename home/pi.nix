# ============================================================================
# Pi Coding Agent Wrapper
#
# Wraps pi so that its bundled Node.js (including npm) is available in PATH
# when pi spawns subprocesses (e.g. "pi install npm:some-extension").
#
# The pi-coding-agent package already depends on nodejs; this wrapper simply
# ensures its bin directory is on PATH so npm, npx etc. work inside pi.
#
# Without this, "pi install" and other npm-backed operations fail with
# "spawn npm ENOENT" because the bundled node's bin dir is not in PATH.
# ============================================================================
{
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # Use the same nodejs from the same channel that provides pi.
  # This is the very same nodejs that pi uses internally – no extra deps.
  piNodejs = pkgs-unstable.nodejs;
in
pkgs.symlinkJoin {
  name = "pi-coding-agent";
  paths = [ pkgs-unstable.pi-coding-agent ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/pi \
      --prefix PATH : ${pkgs.lib.makeBinPath [ piNodejs ]}
  '';
}
