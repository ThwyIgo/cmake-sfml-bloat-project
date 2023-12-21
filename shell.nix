{ pkgs ? import <nixpkgs> {} }:
let sfml = (pkgs.callPackage ./tools/nix/sfml.nix {});
in
pkgs.mkShell {
  inputsFrom = [
    (pkgs.callPackage ./tools/nix/derivation.nix { })
    sfml
  ];

  nativeBuildInputs = with pkgs; [ git cacert ];
  buildInputs = [ sfml ];

  packages = [
    pkgs.clang-tools # clangd
  ];
}
