{ lib
, stdenv
, fetchzip
, fetchpatch
, boost
, cairo
, dejavu_fonts
, freetype
, gdal
, harfbuzz
, icu
, libjpeg
, libpng
, libtiff
, libwebp
, libxml2
, postgresql
, proj
, python3
, sqlite
, zlib
}:

stdenv.mkDerivation rec {
  pname = "mapnik";
  version = "3.1.0";

  src = fetchzip {
    # this one contains all git submodules and is cheaper than fetchgit
    url = "https://github.com/mapnik/mapnik/releases/download/v${version}/mapnik-v${version}.tar.bz2";
    sha256 = "sha256-qqPqN4vs3ZsqKgnx21yQhX8OzHca/0O+3mvQ/vnC5EY=";
  };

  patches = [
    # Fix for Scons with newer Python (https://github.com/mapnik/mapnik/pull/4294)
    (fetchpatch {
      url = "https://github.com/mapnik/mapnik/commit/7da9009e7ffffb0b9429890f6f13fee837ac320f.patch";
      hash = "sha256-0c+4j43mgy04gopGhQk7Jmfr/caENFlMYK18lf+RVNs=";
    })
    # Fix for Boost 1.83 (https://github.com/mapnik/mapnik/pull/4413)
    (fetchpatch {
      url = "https://github.com/mapnik/mapnik/commit/26eb76cc07210d564d80d98948770c94d27c5243.patch";
      hash = "sha256-Q+uIhHtnRAktdZHm0nkuR6ReY42tkaIvPaw5CmhWAVg=";
    })
    # Fix for newer GCC (https://github.com/mapnik/mapnik/pull/4414)
    (fetchpatch {
      url = "https://github.com/mapnik/mapnik/commit/eaa9444201aa72535514ea1c538b351892032e9e.patch";
      hash = "sha256-H7ssQvkDXX3iyPEEiTviN5PGPWSiCp1b6WMupWfUi3s=";
    })
    # Fix for Boost 1.80 (https://github.com/mapnik/mapnik/pull/4414)
    (fetchpatch {
      url = "https://github.com/mapnik/mapnik/commit/a3b6d4a50b1a3253b1cc840cdd14faf094d8bd42.patch";
      hash = "sha256-C8MZKXokE4HP/4guYIoorgObm0Fe+D19qlUhG5M7k7I=";
    })
    # Fix for newer Proj API
    (fetchpatch {
      url = "https://github.com/mapnik/mapnik/commit/8944e81367d2b3b91a41e24116e1813c01491e5d.patch";
      hash = "sha256-EvoRowV3cMshQJLpLg3nF0ZEMbEB7Q5kKdviuZd7T3k=";
    })
  ];

  # a distinct dev output makes python-mapnik fail
  outputs = [ "out" ];

  nativeBuildInputs = [ python3 ];

  buildInputs = [
    boost
    cairo
    freetype
    gdal
    harfbuzz
    icu
    libjpeg
    libpng
    libtiff
    libwebp
    postgresql
    proj
    python3
    sqlite
    zlib
  ];

  propagatedBuildInputs = [ libxml2 ];

  prefixKey = "PREFIX=";

  preConfigure = ''
    patchShebangs ./configure
  '';

  configureFlags = [
    "BOOST_INCLUDES=${boost.dev}/include"
    "BOOST_LIBS=${boost.out}/lib"
    "CAIRO_INCLUDES=${cairo.dev}/include"
    "CAIRO_LIBS=${cairo.out}/lib"
    "FREETYPE_INCLUDES=${freetype.dev}/include"
    "FREETYPE_LIBS=${freetype.out}/lib"
    "GDAL_CONFIG=${gdal}/bin/gdal-config"
    "HB_INCLUDES=${harfbuzz.dev}/include"
    "HB_LIBS=${harfbuzz.out}/lib"
    "ICU_INCLUDES=${icu.dev}/include"
    "ICU_LIBS=${icu.out}/lib"
    "JPEG_INCLUDES=${libjpeg.dev}/include"
    "JPEG_LIBS=${libjpeg.out}/lib"
    "PNG_INCLUDES=${libpng.dev}/include"
    "PNG_LIBS=${libpng.out}/lib"
    "PROJ_INCLUDES=${proj.dev}/include"
    "PROJ_LIBS=${proj.out}/lib"
    "SQLITE_INCLUDES=${sqlite.dev}/include"
    "SQLITE_LIBS=${sqlite.out}/lib"
    "SYSTEM_FONTS=${dejavu_fonts.out}/share/fonts/truetype"
    "TIFF_INCLUDES=${libtiff.dev}/include"
    "TIFF_LIBS=${libtiff.out}/lib"
    "WEBP_INCLUDES=${libwebp}/include"
    "WEBP_LIBS=${libwebp}/lib"
    "XMLPARSER=libxml2"
    # Required for Boost 1.81
    # https://github.com/mapnik/mapnik/issues/4375
    "CUSTOM_DEFINES=-DBOOST_PHOENIX_STL_TUPLE_H_"
  ];

  buildFlags = [
    "JOBS=$(NIX_BUILD_CORES)"
  ];

  meta = with lib; {
    description = "An open source toolkit for developing mapping applications";
    homepage = "https://mapnik.org";
    maintainers = with maintainers; [ hrdinka ];
    license = licenses.lgpl21Plus;
    platforms = platforms.all;
  };
}
