{ lib, stdenv, fetchFromGitHub, cmake}:

stdenv.mkDerivation rec {
  pname = "unity";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "ThrowTheSwitch";
    repo = "Unity";
    rev = version;
    sha256 = "sha256-SCcUGNN/UJlu3ALJiZ9bQKxYRZey3cm9QG+NOehp6Ow=";
  };

  nativeBuildInputs = [ cmake ];

  doCheck = true;

  meta = with lib; {
    description = "Simple Unit Testing for C";
    license = licenses.mit;
  };
}
