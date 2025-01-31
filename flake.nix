{
  description = "A development environment with Zig and Raylib";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    overlays = [
      (final: prev: {
        zigpkgs = inputs.zig.packages.${prev.system};
      })
    ];

    systems = builtins.attrNames inputs.zig.packages;
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {inherit overlays system;};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            zigpkgs.master
            zls
            pkg-config  # For finding libraries if needed
            sokol
            alsa-lib
            libglvnd
            libGL
            libGLU
            xorg.libXcursor
            xorg.libXi
            xorg.libX11
            xorg.libXrandr
            xorg.libXinerama
            xorg.xrandr
            xorg.xdpyinfo
          ];

          shellHook = if pkgs.stdenv.isDarwin then ''
            echo "Development environment with Zig and Raylib is ready for MacOS."
            unset SDKROOT DEVELOPER_DIR
          '' else ''
            echo "Development environment with Zig and Raylib is ready for linux."
          '';
        };

        # For compatibility with older versions of the `nix` binary
        devShell = self.devShells.${system}.default;
      }
    );
}
