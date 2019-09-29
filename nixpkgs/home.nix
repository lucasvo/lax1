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
    i3lock
    git
    dmenu
    feh
    gimp
    evince
    transmission 
    haskellPackages.xmobar
    haskellPackages.yeganesh
    haskellPackages.taffybar
 ];
  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c d71717";
  };
  xsession = {
    enable = true;
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ-AA";
      size = 48;
    };
    profileExtra = ''
feh --bg-scale ~/.config/joris-berthelot-EnTU_hr9wPA-unsplash.jpg &
# xloadimage -onroot -fullscreen ~/.config/joris-berthelot-EnTU_hr9wPA-unsplash.jpg
''; 
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmobar
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
