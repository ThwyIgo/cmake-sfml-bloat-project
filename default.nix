{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./nix/derivation.nix { sfml = pkgs.callPackage ./nix/sfml.nix {}; }
