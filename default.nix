{ mkDerivation, aeson, base, bytestring, containers, polysemy
, polysemy-plugin, stdenv, text
}:
mkDerivation {
  pname = "csvparser";
  version = "0.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson base bytestring containers polysemy polysemy-plugin text
  ];
  executableHaskellDepends = [ base ];
  testHaskellDepends = [ base ];
  homepage = "https://github.com/kowainik/csvparser";
  description = "fdsa";
  license = stdenv.lib.licenses.mit;
}
