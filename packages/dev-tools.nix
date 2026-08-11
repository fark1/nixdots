{ pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];

  environment.systemPackages = [
    # Rust with the wasm32-wasip2 target, so Gram/Zed can compile Wasm
    # extensions locally (e.g. language-support extensions) instead of
    # needing a precompiled bundle. clang alongside it is what lets
    # Gram fetch just the WASI sysroot rather than the full WASI SDK -
    # see the "Installing Extensions" docs.
    (pkgs.rust-bin.stable.latest.default.override {
      targets = [ "wasm32-wasip2" ];
    })
    pkgs.clang

    pkgs.go
  ];
}
