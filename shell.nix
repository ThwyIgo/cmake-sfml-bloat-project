{ pkgs ? import <nixpkgs> {} }:
let sfml = (pkgs.callPackage ./nix/sfml.nix {});
in
pkgs.mkShell {
  inputsFrom = [
    (pkgs.callPackage ./nix/derivation.nix { })
    sfml
  ];

  nativeBuildInputs = with pkgs; [ git cacert ];
  buildInputs = [ sfml ];

  packages = [
    pkgs.clang-tools # clangd
  ];
}
