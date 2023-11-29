{ lib
, stdenv
, callPackage
, cmake
, sfml
, boost182
}:

stdenv.mkDerivation {
  # Use `nix-build --tarball-ttl 0` if you don't want to wait 1h to fetchGit again
  pname = "MyProject";
  version = "0.0.1";
  src = builtins.fetchGit {
    url = ../.git;
    shallow = true;
    ref = "main";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ sfml boost182 ];

  cmakeFlags = [
    "-DfetchSFML=OFF"
    "-DfetchBoost=OFF"
    "-DUSE_RELATIVE_PATHS=ON"
  ];

  meta = with lib; {
    homepage = "https://example.com";
    description = "My description";
    license = licenses.free;
    mainProgram = MyProject; # Executable name
    platforms = platforms.linux;
  };
}
