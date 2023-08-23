{
  description = "foo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        imports = [
          {
            _module.args.pkgs = import inputs.nixpkgs {
              overlays = [(import inputs.rust-overlay)];
              inherit system;
            };
          }
        ];
        devShells.default = pkgs.mkShell {
          inputsFrom = [config.packages.foo];
          packages = with pkgs; [
            clippy
            pre-commit
            rust-analyzer
            rustfmt
            rustPackages.clippy
            glxinfo
            vscode-extensions.llvm-org.lldb-vscode
            taplo
            glib-networking
          ];
          LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
          GIO_MODULE_DIR = "${pkgs.glib-networking}/lib/gio/modules/";
        };

        packages =
          {
            foo = pkgs.rustPlatform.buildRustPackage {
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
                (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
              ];
              buildInputs = with pkgs; [
                libGL
                libGLU
                mesa
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
              ];
            };
          }
          // {default = config.packages.foo;};

        formatter = pkgs.alejandra;
      };
    };
}
