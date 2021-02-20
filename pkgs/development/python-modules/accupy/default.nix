{ lib
, buildPythonPackage
, fetchPypi
, mpmath
, numpy
, pipdate
, pybind11
, pyfma
, eigen
, pytestCheckHook
, matplotlib
, isPy27
}:

buildPythonPackage rec {
  pname = "accupy";
  version = "0.3.4";
  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "36506aca53154528997ac22aee6292c83da0f4850bb375c149512b5284bd4948";
  };

  buildInputs = [
    pybind11 eigen
  ];

  propagatedBuildInputs = [
    mpmath
    numpy
    pipdate
    pyfma
  ];

  checkInputs = [
    pytestCheckHook
    matplotlib
  ];

  postConfigure = ''
   substituteInPlace setup.py \
     --replace "/usr/include/eigen3/" "${eigen}/include/eigen3/"
  '';

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  # performance tests aren't useful to us and disabling them allows us to
  # decouple ourselves from an unnecessary build dep
  preCheck = ''
    for f in test/test*.py ; do
      substituteInPlace $f --replace 'import perfplot' ""
    done
  '';
  disabledTests = [ "test_speed_comparison1" "test_speed_comparison2" ];
  pythonImportsCheck = [ "accupy" ];

  meta = with lib; {
    description = "Accurate sums and dot products for Python";
    homepage = "https://github.com/nschloe/accupy";
    license = licenses.mit;
    maintainers = [ maintainers.costrouc ];
  };
}
