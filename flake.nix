{
  description = "foo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        system,
        ...
      }: let
        overlays = [(import inputs.rust-overlay) (inputs.nixgl.overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rustPlatform = pkgs.makeRustPlatform {
          rustc = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
          cargo = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
        };
      in {
        devShells.default = pkgs.mkShell {
          inputsFrom = [config.packages.foo];
          packages = with pkgs; [
            pre-commit
            glxinfo
            vscode-extensions.llvm-org.lldb-vscode
            taplo
            glib-networking
            inputs.nixgl.packages.${system}.default
          ];
          LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
          GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules/";
        };

        packages =
          {
            foo = rustPlatform.buildRustPackage {
              pname = "foo";
              version = "0.1.0";
              src = ./.;
              cargoLock = {
                lockFile = ./Cargo.lock;
              };
              GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules/";
              LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";

              nativeBuildInputs = with pkgs; [
                pkg-config
                wrapGAppsHook4
              ];
              buildInputs = with pkgs; [
                libGL
                libGLU
                mesa
                mesa.drivers
                gobject-introspection
                gnutls
                webkitgtk_6_0
                libsoup_3
                glib
                glib-networking
                libxml2
                gettext
                cairo
                gtk4
                gtk4-layer-shell
                egl-wayland
                wayland
                vulkan-loader
                vulkan-validation-layers
                vulkan-headers
                vulkan-tools
                libinput
              ];
            };
          }
          // {default = config.packages.foo;};

        formatter = pkgs.alejandra;
      };
    };
}
