{ withHoogle ? false
}:
let
  pinnedPkgs = (import ./nix/nix-ghc-ptr.nix).pinnedPkgs;

  customHaskellPackages = pinnedPkgs.haskellPackages.override (old: {
    overrides = pinnedPkgs.lib.composeExtensions (old.overrides or (_: _: {})) (self: super: {
      project1 = self.callCabal2nix "csvparser" ./csvparser.cabal { };
      polysemy = self.callPackage ./nix/lib/polysemy.nix { };
      polysemy-plugin = self.callPackage ./nix/lib/polysemy-plugin.nix { };
      # addditional overrides go here
    });
  });

  hoogleAugmentedPackages = import ./nix/toggle-hoogle.nix { withHoogle = withHoogle; input = customHaskellPackages; };

in
  { project1 = hoogleAugmentedPackages.project1;
  }