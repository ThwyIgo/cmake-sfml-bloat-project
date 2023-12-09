{ lib
, stdenv
, callPackage
, cmake
, sfml
, boost182
}:

stdenv.mkDerivation {
  pname = "MyProject";
  version = "0.0.1";
  # Don't include result and out directories in the derivation.
  src = builtins.filterSource
    (path: type: !(builtins.elem type [ "directory" "symlink" ] &&
                   builtins.elem (baseNameOf path) [
                     "result"
                     "out"
                   ]))
    ../.;

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
