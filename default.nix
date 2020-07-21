{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs {
    # Uncomment this to produce a working executable.
    # overlays = [writePython3FixedOverlay];
  };

  writePython3FixedOverlay = self: super: {
    writers = super.writers // {
      writePython3 = name: { libraries ? [], flakeIgnore ? [] }:
      let
        py = super.python3.withPackages (ps: libraries);
        ignoreAttribute = super.lib.optionalString (flakeIgnore != []) "--ignore ${super.lib.concatMapStringsSep "," super.lib.escapeShellArg flakeIgnore}";
      in
      super.writers.makeScriptWriter {
        interpreter = "${self.coreutils}/bin/env ${py}/bin/python";
        check = super.writers.writeDash "python3check.sh" ''
          exec ${super.python3Packages.flake8}/bin/flake8 --show-source ${ignoreAttribute} "$1"
        '';
      } name;
    };
  };
in
  pkgs.writers.writePython3
    "test_yaml"
    { libraries = [ pkgs.python3Packages.pyyaml ]; }
    ./script.py