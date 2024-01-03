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
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "SFML";
    repo = "SFML";
    rev = "872faccc972d91d8e8080201a1806614c975c146";
    sha256 = "sha256-24oC8xzXaxB+695rm9HxrgsVv+LsVQbKuiOEqTMw8X4=";
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
