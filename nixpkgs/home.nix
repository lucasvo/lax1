{ pkgs, ...}:
{ 
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    rxvt_unicode
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
      ]; 
      config = pkgs.writeText "xmonad.hs" ''
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Circle
import XMonad.Layout.BinarySpacePartition
import System.IO
import XMonad.Actions.KeyRemap ( KeymapTable (..)
    , buildKeyRemapBindings
    , setDefaultKeyRemap
    , setKeyRemap
    , emptyKeyRemap )

primaryColor = "#df5f5f"
bgColor      = "#1c1c1c"

myFocusedBorderColor = primaryColor
myNormalBorderColor  = bgColor

myLayoutHook = ThreeColMid 1 (3/100) (1/2)
  ||| emptyBSP

myKeyRemap = KeymapTable [ ((0, xK_i), (0, xK_I))
                         ]

main = do
    xmproc <- spawnPipe "xmobar"

    xmonad $ docks defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , terminal   = "kitty"
        , handleEventHook = ewmhDesktopsEventHook
        , layoutHook = smartSpacing 4 $ smartBorders $ avoidStruts $ myLayoutHook --defaultConfig
        , logHook = ewmhDesktopsLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor primaryColor ""
                        , ppTitle = xmobarColor primaryColor "" . shorten 50
                        }
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        , focusedBorderColor = myFocusedBorderColor
        , borderWidth        = 2
        , normalBorderColor  = myNormalBorderColor
        , startupHook = do
          setDefaultKeyRemap emptyKeyRemap [emptyKeyRemap, myKeyRemap]
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot screen_%Y-%m-%d-%H-%M-%S.png -d 1")
        , ((mod4Mask, xK_p), spawn "rofi -show run")
        , ((0, 0x1008ff03), spawn "light -S $(echo $(light -G)/2|bc)")
        , ((0, 0x1008ff02), spawn "light -S $(echo \"$(light -G)*2+0.1\"|bc)")
        , ((0, 0x1008ff12), spawn "amixer -q set Master toggle")
        , ((0, 0x1008ff11), spawn "amixer -q set Master 10%-")
        , ((0, 0x1008ff13), spawn "amixer -q set Master 10%+")
        ]
'';
    }; 
  };
  # services.taffybar.enable = true;
  xresources.properties = {
    "Xft.dpi" = 180;
    "Xft.autohint" = 0;
    "Xft.lcdfilter" = "lcddefault";
    "Xft.hintstyle" = "hintful";
    "Xft.hinting" = 1;
    "Xft.antialias" = 1;
    "Xft.rgba" = "rgb";
  };
}
