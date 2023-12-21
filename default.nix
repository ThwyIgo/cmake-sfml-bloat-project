{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./tools/nix/derivation.nix { sfml = pkgs.callPackage ./tools/nix/sfml.nix {}; }
