{ config, pkgs, ... }:
let
  dracula-zsh = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "zsh";
    rev = "master";
    hash = "sha256-unPUH3D89gH0j8/kv1Dl+ybR5n8UX0hJ+SuETtgpJOo=";
  };

  terminalProfile = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
in
{
  home.username = "ivan";
  home.homeDirectory = "/home/ivan";
  home.stateVersion = "26.05";

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  home.packages = with pkgs; [
    git
    htop
    signal-desktop
    protonmail-desktop
    nixd # Language server for auto-completion and diagnostics
    nixfmt # Formatter for .nix files
    gnome-terminal
    openscad
    devenv
  ];

  home.shellAliases = {
    emacs = "emacs -nw"; # Opens Emacs in terminal mode by default
    ec = "emacsclient -t"; # Opens an Emacs client terminal frame
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Loaded before .zshrc and Oh My Zsh.
    envExtra = ''
      export ZSH_TMUX_AUTOSTART=true
      export ZSH_TMUX_AUTOCONNECT=true
    '';

    oh-my-zsh = {
      enable = true;
      custom = "${dracula-zsh}";
      theme = "dracula";
      plugins = [
        "git"
        "sudo"
        "tmux"
      ];
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g default-shell "${pkgs.zsh}/bin/zsh"
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "ivan@metzlar.ca";
        name = "metzlar";
      };
      alias = {
        co = "checkout";
        ci = "commit";
        st = "status";
        br = "branch";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs; # or pkgs.emacs-gtk / pkgs.emacs-pgtk
    extraPackages =
      epkgs: with epkgs; [
        nix-mode # Major mode for .nix files
        eglot # Built-in or MELPA LSP client
        corfu # Completion UI (optional, or use company)
        company # Alternative completion framework
        dracula-theme
      ];
    extraConfig = ''
      ;; Enable desktop-save-mode to preserve open files across sessions
      (require 'desktop)
      ;; Set the directory where the .emacs.desktop file will be saved
      (let ((desktop-directory                                                                                                                                             
           (expand-file-name "desktop/" user-emacs-directory)))                                                                                                          
      (make-directory desktop-directory t)                                                                                                                               
      (setq desktop-path (list desktop-directory)                                                                                                                        
            desktop-dirname desktop-directory                                                                                                                            
            desktop-save t                                                                                                                                               
            desktop-load-locked-desktop nil)                                                                                                                             
      (desktop-save-mode 1))

      ;; Load dracula-theme
      (load-theme 'dracula t)

      ;; Enable nix-mode for .nix files
      (use-package nix-mode
        :mode "\\.nix\\'"
        :hook (nix-mode . eglot-ensure))

      ;; Configure eglot to use nixd
      (with-eval-after-load 'eglot
        (add-to-list 'eglot-server-programs
                     '(nix-mode . ("nixd"))))

      ;; Format before save using nixfmt
      (add-hook 'nix-mode-hook
                (lambda ()
                  (add-hook 'before-save-hook #'eglot-format nil t)))
    '';
  };

  services.emacs = {
    enable = true;
    defaultEditor = true; # Sets EDITOR=emacsclient in your user environment
    client = {
      enable = true; # Generates an "Emacs (Client)" .desktop item
      arguments = [ "-c" ]; # Automatically opens a new graphical frame
    };
  };

  xdg.desktopEntries = {
    "proton-mail" = {
      name = "Proton Mail";
      exec = "proton-mail %U";
      icon = "protonmail"; # Or specify a path to a custom icon if the default isn't picked up
      comment = "Proton Mail Desktop Client";
      categories = [
        "Network"
        "Email"
      ];
      mimeType = [ "x-scheme-handler/mailto" ];
      settings = {
        # Optional: Forces X11 mode if the app screen is blank/flickering under Wayland
        # Exec = "proton-mail --ozone-platform=x11 %U";
      };
    };
  };

  # Hardship to get gnome-terminal to use Dracula colors
  dconf.settings = {
    "org/gnome/terminal/legacy/profiles:" = {
      default = terminalProfile;
      list = [ terminalProfile ];
    };

    "org/gnome/terminal/legacy/profiles:/:${terminalProfile}" = {
      visible-name = "Dracula";

      use-theme-colors = false;
      foreground-color = "#F8F8F2";
      background-color = "#282A36";

      palette = [
        "#21222C"
        "#FF5555"
        "#50FA7B"
        "#F1FA8C"
        "#BD93F9"
        "#FF79C6"
        "#8BE9FD"
        "#F8F8F2"
        "#6272A4"
        "#FF6E6E"
        "#69FF94"
        "#FFFFA5"
        "#D6ACFF"
        "#FF92DF"
        "#A4FFFF"
        "#FFFFFF"
      ];
    };
  };

}
