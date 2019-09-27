{ pkgs, ...}:
let 
  urxvt = import ~/.config/nixpkgs/urxvt.nix { inherit pkgs; };
in
{ 
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs_: with pkgs_; {
    my_1password = import ~/.config/nixpkgs/1password.nix {inherit (pkgs) stdenv fetchzip; };
  };
  home.packages = with pkgs; [
    my_1password
    vlc
    signal-desktop
    slack
    zoom-us
    firefox
    rxvt_unicode-with-plugins
    taffybar
    i3lock
    git
  ];
  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
  };
  xsession = {
    enable = true;
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ-AA";
      size = 48;
    };
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.taffybar
        haskellPackages.yeganesh
      ]; 
      config = ~/.config/xmonad/xmonad.hs; 
    }; 
  };

  xresources.extraConfig = builtins.readFile ~/.config/xresources;

  programs.git = {
    userEmail = ''l@lucasvo.com'';
    userName = ''Lucas Vogelsang'';
  };

}
