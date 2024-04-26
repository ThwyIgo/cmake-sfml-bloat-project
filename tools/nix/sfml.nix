let sfmlAllModules = [ "audio" "graphics" "window" "network" ];
in
{ lib
, stdenv
, fetchFromGitHub
, cmake
, libX11
, libXcursor
, libGL
, freetype
, openal
, flac
, libvorbis
, libXrandr
, libXrender
, udev
# SFML modules that will be built
, sfmlModules ? sfmlAllModules
}:

lib.checkListOfEnum "sfml: Modules" sfmlAllModules sfmlModules
stdenv.mkDerivation {
  pname = "sfml";
  version = "2.6.2-unreleased";

  src = fetchFromGitHub {
    owner = "SFML";
    repo = "SFML";
    rev = "b0e25088a291772fad8364372bcff9728512579c";
    sha256 = "sha256-aAAdSxWJqBgjzcD4GTLMABDqp8cmqoyIedGLWVRgcqA=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = lib.optionals stdenv.isLinux [
    freetype
    libX11
    libXrandr
    libXrender
    libXcursor
    udev
    libGL
    flac
    libvorbis
    openal
  ];

  cmakeFlags = [
    "-DSFML_INSTALL_PKGCONFIG_FILES=TRUE"
    "-DSFML_USE_SYSTEM_DEPS=TRUE"
  ] ++
  builtins.map (m: "-DSFML_BUILD_" + lib.toUpper m +
                   (if builtins.elem m sfmlModules
                    then "=TRUE"
                    else "=FALSE")
  ) sfmlAllModules;

  meta = with lib; {
    homepage = "https://www.sfml-dev.org/";
    description = "Simple and fast multimedia library";
    longDescription = ''
      SFML is a simple, fast, cross-platform and object-oriented multimedia API.
      It provides access to windowing, graphics, audio and network.
      It is written in C++, and has bindings for various languages such as C, .Net, Ruby, Python.
    '';
    license = licenses.zlib;
    platforms = platforms.unix;
  };
}
