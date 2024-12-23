{
  description = "Flake to build and configure dmenu from Catppuccin's repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux"; # Adjust to your system if needed
    };
  in {
    packages.x86_64-linux = {
      dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: rec {
        pname = "dmenu-catppuccin";
        version = "main";

        # src = pkgs.fetchFromGitHub {
        #   owner = "catppuccin";
        #   repo = "dmenu";
        #   rev = "main";
        #   sha256 = "1x64nyv29gg8x403j8dlfj86kg4y6y20b1i56nph9s85sfs3abaj"; # Replace with actual sha256
        # };

        nativeBuildInputs = [ pkgs.pkg-config pkgs.tree pkgs.xorg.libX11 pkgs.xorg.libXft pkgs.xorg.libXinerama ];
        # Extrae todos los archivos necesarios directamente
        prePatch = ''
          mkdir compiler
          tar -xzf ${pkgs.dmenu.src} -C ./compiler/ --strip-components=1
          cd compiler
          #tree
        '';

        buildPhase = ''
          cp ${./config.h} ./config.h
          make
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp dmenu $out/bin/
          cp dmenu_run $out/bin/
          cp dmenu_path $out/bin/
        '';

        meta = with pkgs.lib; {
          description = "Dmenu with Catppuccin theme";
          homepage = "https://github.com/catppuccin/dmenu";
          license = licenses.mit;
        };
      });
    };

    apps.x86_64-linux = {
      dmenu = {
        type = "app";
        program = "${self.packages.x86_64-linux.dmenu}/bin/dmenu";
      };
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.dmenu;
    defaultApp.x86_64-linux = self.apps.x86_64-linux.dmenu;
  };
}


