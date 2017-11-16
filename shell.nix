{ pkgs ? import <nixpkgs> {}
, system ? builtins.currentSystem
}:

let
  nodePackages = import ./default.nix {
    inherit pkgs system;
  };
in {
  shell = nodePackages.shell.override {
    shellHook = ''
      # Because Grunt must be installed locally...
      if [[ ! -e node_modules ]]; then
        ln -s "$nodeDependencies/lib/node_modules" node_modules
      fi
      # Automatically start the server
      exec npm start
    '';
  };
}
