{ mkDerivation, base, criterion, fetchgit, free, freer-simple
, hspec, inspection-testing, mtl, random, stdenv, syb
, template-haskell, transformers
}:
mkDerivation {
  pname = "polysemy";
  version = "0.2.0.0";
  src = fetchgit {
    url = "https://github.com/isovector/polysemy";
    sha256 = "1zvax8zdhsf23rvbr2nvk2sw55y0c2jqync1b5bpvfmzw0pjy95f";
    rev = "aefb1deef03c26a5f5790f4f1123ec6f7f5de9ee";
  };
  libraryHaskellDepends = [
    base mtl random syb template-haskell transformers
  ];
  testHaskellDepends = [
    base hspec inspection-testing mtl random syb template-haskell
    transformers
  ];
  benchmarkHaskellDepends = [
    base criterion free freer-simple mtl random syb template-haskell
    transformers
  ];
  homepage = "https://github.com/isovector/polysemy#readme";
  description = "Higher-order, low-boilerplate, zero-cost free monads";
  license = stdenv.lib.licenses.bsd3;
}
