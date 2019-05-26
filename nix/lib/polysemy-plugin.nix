{ mkDerivation, base, fetchgit, ghc, ghc-tcplugins-extra, hpack
, hspec, polysemy, should-not-typecheck, stdenv
}:
mkDerivation {
  pname = "polysemy-plugin";
  version = "0.2.0.0";
  src = fetchgit {
    url = "https://github.com/isovector/polysemy";
    sha256 = "1zvax8zdhsf23rvbr2nvk2sw55y0c2jqync1b5bpvfmzw0pjy95f";
    rev = "aefb1deef03c26a5f5790f4f1123ec6f7f5de9ee";
  };
  doCheck = false;
  postUnpack = "sourceRoot+=/polysemy-plugin; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [ base ghc ghc-tcplugins-extra polysemy ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base ghc ghc-tcplugins-extra hspec polysemy should-not-typecheck
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/isovector/polysemy#readme";
  description = "Disambiguate obvious uses of effects";
  license = stdenv.lib.licenses.bsd3;
}
