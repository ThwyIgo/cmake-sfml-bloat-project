{ pkgs ? import <nixpkgs> {} }:
let default = import ./default.nix { inherit pkgs; };
    sfml = pkgs.lib.findFirst (drv:
      (builtins.parseDrvName drv.name).name == "sfml"
    ) pkgs.sfml default.buildInputs;
in

pkgs.mkShell {
  inputsFrom = [
    default
    sfml
  ];

  nativeBuildInputs = with pkgs; [ git cacert ];

  # sfml gets deleted from inputsFrom even though it is an input of ./default.nix.
  # This is just how inputsFrom works.
  buildInputs = [ sfml ];

  packages = [
    pkgs.clang-tools # clangd
  ];
}
