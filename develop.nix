{ pkgs }: with pkgs; let

in haskellPackages.shellFor {
  packages = p: [ ten-days-of-grad ];
  buildInputs =
    (with haskellPackages;
    [ haskell-language-server

    ]) ++
    [ cabal-install ];
}
