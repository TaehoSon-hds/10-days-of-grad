final: prev: with final; {

  myHaskellPackages = prev.haskellPackages.override (old: {
    overrides = lib.composeManyExtensions [
      (old.overrides or (_: _: {}))
      (hfinal: hprev: with haskell.lib; {
        ten-days-of-grad = hfinal.callCabal2nix "ten-days-of-grad" ./. {};
      })
    ];
  });

  ten-days-of-grad = haskell.lib.justStaticExecutables myHaskellPackages.ten-days-of-grad;

}
