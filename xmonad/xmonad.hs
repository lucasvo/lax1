-- system imports
import Control.Monad
import Control.Monad.Trans
import Data.Bits ((.|.))
import Data.Map (fromList)
import Data.Monoid
import Data.Ratio
import GHC.Real
import System.Exit

-- xmonad core
import XMonad
import XMonad.StackSet hiding (workspaces)

-- xmonad contrib
import XMonad.Actions.SpawnOn
import XMonad.Actions.Volume
import XMonad.Actions.Warp
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Layout.Grid
import XMonad.Layout.IndependentScreens
import XMonad.Layout.Magnifier
import XMonad.Layout.NoBorders
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spacing
import XMonad.Util.Dzen
import XMonad.Util.EZConfig
import XMonad.Util.Run

centerMouse = warpToWindow (1/2) (1/2)
statusBarMouse = warpToScreen 0 (5/1600) (5/1200)
withScreen screen f = screenWorkspace screen >>= flip whenJust (windows . f)

makeLauncher yargs run exec close = concat
    ["exe=`yeganesh ", yargs, "` && ", run, " ", exec, "$exe", close]
launcher     = makeLauncher "" "eval" "\"exec " "\""
termLauncher = makeLauncher "-p withterm" "exec urxvt -e" "" ""
viewShift  i = view i . shift i
floatAll     = composeAll . map (\s -> className =? s --> doFloat)
sinkFocus    = peek >>= maybe id sink
onChannels f = f ("Front":"Headphone":defaultChannels) 4 >>= volumeDzen . show . round
volumeDzen   = dzenConfig $ onCurr (center 170 66) >=> font "-*-helvetica-*-r-*-*-64-*-*-*-*-*-*-*,-*-terminus-*-*-*-*-64-*-*-*-*-*-*-*"

bright = "#80c0ff"
dark   = "#13294e"

fullscreenMPlayer = className =? "MPlayer" --> do
    dpy   <- liftX $ asks display
    win   <- ask
    hints <- liftIO $ getWMNormalHints dpy win
    case fmap (approx . fst) (sh_aspect hints) of
        Just ( 4 :% 3)  -> viewFullOn win 0 "1"
        Just (16 :% 9)  -> viewFullOn win 1 "5"
        _               -> doFloat
    where
    fi               = fromIntegral
    approx (n, d)    = approxRational (fi n / fi d) (1/100)
    viewFullOn w s n = do
        let ws = marshall s n
        liftX  $ withScreen s view
        return . Endo $ view ws . shiftWin ws w

myLayoutHook = ThreeColMid 1 (3/100) (1/2)
  ||| emptyBSP

main = do
    nScreens    <- countScreens
--    hs          <- mapM (spawnPipe . xmobarCommand) [0 .. nScreens-1]
    xmproc  <- spawnPipe "xmobar"
    xmonad $ docks defaultConfig {
        borderWidth             = 2,
        workspaces              = withScreens nScreens (map show [1..5]),
        terminal                = "urxvt",
        normalBorderColor       = dark,
        focusedBorderColor      = bright,
        modMask                 = mod4Mask,
        keys                    = keyBindings,
        layoutHook              = smartSpacing 4 $ smartBorders $ avoidStruts $ myLayoutHook,  
        manageHook              = floatAll ["Gimp", "Wine"]
                                  <+> (title =? "CGoban: Main Window" --> doF sinkFocus)
                                  <+> (isFullscreen --> doFullFloat)
                                  <+> fullscreenMPlayer
                                  <+> manageDocks
                                  <+> manageSpawn,
        handleEventHook         = ewmhDesktopsEventHook,
        logHook                 = ewmhDesktopsLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor bright ""
                        , ppTitle = xmobarColor bright "" . shorten 50
                        }
        }

keyBindings conf = let m = modMask conf in fromList $ [
    ((m                , xK_BackSpace  ), spawnHere "urxvt"),
    ((m                , xK_p          ), spawnHere launcher),
    ((m .|. shiftMask  , xK_p          ), spawnHere termLauncher),
    ((m .|. shiftMask  , xK_c          ), kill),
    ((m                , xK_q          ), restart "xmonad" True),
    ((m .|. shiftMask  , xK_q          ), io (exitWith ExitSuccess)),
    ((m                , xK_grave      ), sendMessage NextLayout),
    ((m .|. shiftMask  , xK_grave      ), setLayout $ layoutHook conf),
    ((m                , xK_o          ), sendMessage Toggle),
    ((m                , xK_b          ), sendMessage ToggleStruts),
    ((m                , xK_x          ), withFocused (windows . sink)),
    ((m                , xK_Home       ), windows focusUp),
    ((m .|. shiftMask  , xK_Home       ), windows swapUp),
    ((m                , xK_End        ), windows focusDown),
    ((m .|. shiftMask  , xK_End        ), windows swapDown),
    ((m                , xK_a          ), windows focusMaster),
    ((m .|. shiftMask  , xK_a          ), windows swapMaster),
    ((m                , xK_Control_L  ), withScreen 0 view),
    ((m .|. shiftMask  , xK_Control_L  ), withScreen 0 viewShift),
    ((m                , xK_Alt_L      ), withScreen 1 view),
    ((m .|. shiftMask  , xK_Alt_L      ), withScreen 1 viewShift),
    ((m                , xK_u          ), centerMouse),
    ((m .|. controlMask, xK_u          ), centerMouse),
    ((m .|. mod1Mask   , xK_u          ), centerMouse),
    ((m .|. shiftMask  , xK_u          ), statusBarMouse),
    ((m                , xK_s          ), spawn "firefox"),
    ((m                , xK_n          ), spawn "urxvt -e vim todo"),
    ((m                , xK_v          ), spawn "urxvt -e vim"),
    ((m                , xK_h          ), spawn "urxvt -e alsamixer"),
    ((m                , xK_d          ), spawn "wyvern"),
    ((m                , xK_l          ), spawn "urxvt -e sup"),
    ((m                , xK_g          ), spawn "i3lock -n -c d71717"),
    ((m                , xK_f          ), spawn "gvim ~/.xmonad/xmonad.hs")
    --((0                , xK_F8         ), onChannels lowerVolumeChannels),
    --((0                , xK_F9         ), onChannels raiseVolumeChannels)
    ] ++ [
    ((m .|. e .|. i    , key           ), windows (onCurrentScreen f workspace))
    | (key, workspace) <- zip [xK_1..xK_9] (workspaces' conf)
    , (e, f)           <- [(0, view), (shiftMask, viewShift)]
    , i                <- [0, controlMask, mod1Mask, controlMask .|. mod1Mask]
    ]

-- TODO: add control/alt mask to all keybindings

xmobarCommand (S s) = unwords ["xmobar", "-x", show s, "-t", template s] where
    template 0 = "%StdinReader%"
    template _ = "%date%%StdinReader%"

pp h s = marshallPP s defaultPP {
    ppCurrent           = color "white",
    ppVisible           = color "white",
    ppHiddenNoWindows   = color dark,
    ppUrgent            = color "red",
    ppSep               = "",
    ppOrder             = \(wss:layout:title:_) -> ["\NUL", title, "\NUL", wss],
    ppOutput            = hPutStrLn h
    }
    where color c = xmobarColor c ""
