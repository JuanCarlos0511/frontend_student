{
  description = "Flutter Android Environment - Fixed";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        # Configuración corregida: cmdLineToolsVersion en singular y como string
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ "34.0.0" "30.0.3" ];
          platformVersions = [ "34" "33" ];
          abiVersions = [ "arm64-v8a" "armeabi-v7a" ];
          cmdLineToolsVersion = "13.0"; # <-- CORREGIDO: Sin 's' al final y es un string
        };

        androidSdk = androidComposition.androidsdk;
      in
      {
        devShell = pkgs.mkShell {
          name = "flutter-env";

          buildInputs = with pkgs; [
            flutter
            jdk17
            androidSdk
            android-tools # Para tener 'adb' siempre a mano
          ];

          shellHook = ''
            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
            export JAVA_HOME="${pkgs.jdk17.home}"
            
            # Vinculamos Nix con la config de Flutter
            flutter config --android-sdk "$ANDROID_HOME"
            flutter config --jdk-dir "$JAVA_HOME"

            echo "✅ Entorno cargado. El error de cmdline-tools debería haber desaparecido."
          '';
        };
      });
}