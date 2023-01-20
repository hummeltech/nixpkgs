{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, curl
, boost
, liboauth
, jsoncpp
, htmlcxx
, rhash
, tinyxml-2
, help2man
, wrapQtAppsHook
, qtbase
, qtwebengine
, testers
, lgogdownloader

, enableGui ? true
}:

stdenv.mkDerivation rec {
  pname = "lgogdownloader";
  version = "3.9";

  src = fetchFromGitHub {
    owner = "Sude-";
    repo = "lgogdownloader";
    rev = "v${version}";
    sha256 = "sha256-Qt9uTKsD0kQ6b9Y5+eC+YWpCHMIJGzP+pMfuUBt/fME=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    help2man
  ] ++ lib.optional enableGui wrapQtAppsHook;

  buildInputs = [
    boost
    curl
    htmlcxx
    jsoncpp
    liboauth
    rhash
    tinyxml-2
  ] ++ lib.optionals enableGui [
    qtbase
    qtwebengine
  ];

  cmakeFlags = lib.optional enableGui "-DUSE_QT_GUI=ON";

  passthru.tests = {
    version = testers.testVersion { package = lgogdownloader; };
  };

  meta = with lib; {
    description = "Unofficial downloader to GOG.com for Linux users. It uses the same API as the official GOGDownloader";
    homepage = "https://github.com/Sude-/lgogdownloader";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
