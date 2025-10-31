{
  description = "isup.website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          {
            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                beamMinimal28Packages.erlang
                beamMinimal28Packages.rebar3
                gleam
              ];
            };
          }
    );
}
