{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  pname = "fasmg";
  version = "k328";

  src = fetchzip {
    url = "https://flatassembler.net/fasmg.${version}.zip";
    sha256 = "sha256-kDMTGfyetG+H8pTKvjnhST1yAX4FkPyog9ovTVJKKJ0=";
    stripRoot = false;
  };

  buildPhase =
    let
      inherit (stdenv.hostPlatform) system;

      path = {
        x86_64-linux = {
          bin = "fasmg.x64";
          asm = "source/linux/x64/fasmg.asm";
        };
        x86_64-darwin = {
          bin = "source/macos/x64/fasmg";
          asm = "source/macos/x64/fasmg.asm";
        };
        x86-linux = {
          bin = "fasmg";
          asm = "source/linux/fasmg.asm";
        };
        x86-darwin = {
          bin = "source/macos/fasmg";
          asm = "source/macos/fasmg.asm";
        };
      }.${system} or (throw "Unsopported system: ${system}");

    in
    ''
      chmod +x ${path.bin}
      ./${path.bin} ${path.asm} fasmg
    '';

  outputs = [ "out" "doc" ];

  installPhase = ''
    install -Dm755 fasmg $out/bin/fasmg

    mkdir -p $doc/share/doc/fasmg
    cp docs/*.txt $doc/share/doc/fasmg
  '';

  meta = with lib; {
    description = "x86(-64) macro assembler to binary, MZ, PE, COFF, and ELF";
    homepage = "https://flatassembler.net";
    license = licenses.bsd3;
    maintainers = with maintainers; [ orivej luc65r ];
    platforms = with platforms; intersectLists (linux ++ darwin) x86;
  };
}
