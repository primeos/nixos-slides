{ system ? builtins.currentSystem }:

let
  pkgs =
    let
      # channels/nixos-17.09 from 2018-08-01
      # TODO: Update to a newer version/channel
      rev = "9e1d8b7470606387555c6b7e4dc62763f0594757";
      hash = "06hllyay069is58vfx1fvldx317ms6ha9zx85v7a836gxsdifj8p";
      nixpkgs = builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        sha256 = hash;
      };
      patches = [ ./reveal-js/0001-phantomjs2-set-QT_QPA_PLATFORM-to-allow-use-in-daemo.patch ];
    in import ((import nixpkgs {}).runCommand
      ("nixpkgs-" + rev)
      { inherit nixpkgs patches; }
      ''
        cp -R $nixpkgs $out
        chmod -R +w $out
        for p in $patches ; do
          echo "Applying patch $p"
          patch -d $out -p1 < "$p"
        done
      '') {};
  nodePackages = import ./reveal-js/default.nix {
    inherit pkgs system;
  };
in {
  shell = nodePackages.shell.override {
    shellHook = ''
      set -o errexit

      # TODO: This is a bit hacky...
      cd reveal-js
      ln -s ../img img
      cp ../index.html index.html
      sed --in-place \
        -e 's,reveal-js/,,g' \
        index.html

      # Because Grunt must be installed locally...
      if [[ ! -e node_modules ]]; then
        ln -s "$nodeDependencies/lib/node_modules" node_modules
      fi

      # Automatically start the server
      exec npm start
    '';
  };
}
