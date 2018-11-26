{-# OPTIONS_GHC -fno-warn-missing-signatures -fno-warn-orphans #-}
{-# LANGUAGE TypeFamilies #-}

import XMonad
import XMonad.Actions.SpawnOn
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.IndependentScreens
import XMonad.Layout.Spacing
import XMonad.Util.Run
import XMonad.Util.WorkspaceCompare

import Control.Monad

import System.Environment
import System.Exit
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map as M



------------------------------------------------------------------------
-- Layout:

-- | The available layout.

layout =
  avoidStruts $
  tiled |||
  Mirror tiled |||
  Full
  where
    -- Default tiling algorithm: split screen in two panes
    tiled = smartSpacing 5 $ Tall masterPanes delta ratio
    -- Default number of windows in the master pane
    masterPanes = 1
    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100




------------------------------------------------------------------------
-- Workspaces:

-- | The list of workspaces.
-- The number of workspaces is determined by the lenght of this list

myWorkspaces :: [WorkspaceId]
myWorkspaces = [ "W1"
               , "W2"
               , "W3"
               , "W4"
               , "W5"
               , "W6"
               , "W7"
               , "W8"
               , "W9" ]


------------------------------------------------------------------------
-- Configuration:

-- | Modifier
myModMask :: KeyMask
myModMask = mod4Mask

-- | Width of the border
myBorderWidth :: Dimension
myBorderWidth = 3

-- | Border color for (un)focused windows.
myNormalBorderColor, myFocusedBorderColor :: String
myNormalBorderColor = "white"
myFocusedBorderColor = "yellow"

-- | Terminal
myTerminal :: String
myTerminal = "konsole"



------------------------------------------------------------------------
-- Hooks:

myManageHook =
  manageDocks <+>
  manageSpawn <+>
  manageHook XMonad.def <+>
  composeOne [ isDialog -?> doFloat
             , transience]



------------------------------------------------------------------------
-- Key bindings:

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf @ (XConfig { XMonad.modMask = modMask }) =
 M.fromList $
 [
   -- Launching and killing programs
   ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf) -- Terminal
 , ((modMask, xK_p), spawn "dmenu_run")                               -- Dmenu
 , ((modMask .|. shiftMask, xK_p), spawn "gmrun")                     -- Gmrun
 , ((modMask .|. shiftMask, xK_c), kill)                              -- Close window

   -- Modifying layout
 , ((modMask, xK_space), sendMessage NextLayout) -- Rotate through available layout
 , ((modMask .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf) -- Reset layout to default
 , ((modMask, xK_n), refresh)                                              -- Resize viewed windows

   -- Window stack
 , ((modMask, xK_Tab), windows W.focusDown) -- Move focus to next window
 , ((modMask .|. shiftMask, xK_Tab), windows W.focusUp) -- Move focus to previous window
 , ((modMask, xK_m), windows W.focusMaster) -- Move focus to master window
 , ((modMask, xK_Return), windows W.swapMaster) -- Swap the focused window and the master window
 , ((modMask .|. shiftMask, xK_j), windows W.swapDown) -- Swap the focused window with the next
 , ((modMask .|. shiftMask, xK_k), windows W.swapUp)   -- Swap the focused window with the prev

   -- Shrink/Expand
 , ((modMask .|. controlMask, xK_Left), sendMessage Shrink)
 , ((modMask .|. controlMask, xK_Right), sendMessage Expand)

   -- Floating layer support
 , ((modMask, xK_t), withFocused $ windows . W.sink) -- Put back the window in Tiling mode.

   -- Increase/Decrease number of windows in the master area
 , ((modMask, xK_comma), sendMessage (IncMasterN 1))
 , ((modMask, xK_period), sendMessage (IncMasterN (- 1)))

   -- Screensaver
 , ((modMask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
 , ((modMask .|. shiftMask .|. controlMask, xK_l), spawn "gksudo systemctl hibernate")

   -- Sound
 , ((modMask .|. controlMask, xK_Up), spawn "amixer sset Master 5%+")
 , ((modMask .|. controlMask, xK_Down), spawn "amixer sset Master 5%-")
 , ((modMask .|. controlMask, xK_m), spawn "~/.xmonad/binaries/amixer-toggle-sound")

   -- Quit/Restart
 , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))
 , ((modMask, xK_q), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi")

 ]
  ++
  -- mod-[1 .. 9]: switch to workspace N
  -- mod-shift-[1 .. 9]: switch application to workspace N
  [ ((modMask .|. m, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) [ xK_ampersand, xK_eacute, xK_quotedbl,
                                             xK_apostrophe, xK_parenleft, xK_minus,
                                             xK_egrave, xK_underscore, xK_ccedilla ]
  , (f, m) <- [ (W.greedyView, 0), (W.shift, shiftMask) ] ]

  ++
  -- mod-[a,z,e]: Switch to screen 1/2/3
  -- mod-shift-[a,z,e]: Move to screen 1/2/3
  [ ((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  | (key, sc) <- zip [ xK_a, xK_z, xK_e ] [ 0 .. ]
  , (f, m) <- [ (W.view, 0), (W.shift, shiftMask) ] ]


------------------------------------------------------------------------
-- Startup:

myStartupHook :: Bool -> X ()
myStartupHook initial = do
  setWMName "LG3D"
  when initial $ do
    spawnOn "W3" "konsole -e 'tmuxp load work-session'"


------------------------------------------------------------------------
-- Main:

myPP =
  XMonad.Hooks.DynamicLog.xmobarPP
  { ppLayout = const ""
  , ppHiddenNoWindows = trim
  , ppSort = getSortByIndex
  , ppTitle = const ""
  , ppTitleSanitize = const ""
  , ppVisible = wrap "(" ")"
  , ppWsSep = " | " }

myConfig args =
  XMonad.def
  { XMonad.borderWidth = myBorderWidth
  , XMonad.workspaces = myWorkspaces
  , XMonad.normalBorderColor = myNormalBorderColor
  , XMonad.focusedBorderColor = myFocusedBorderColor
  , XMonad.terminal = myTerminal
  , XMonad.modMask = myModMask
  , XMonad.keys = myKeys
    -- Hooks
  , XMonad.layoutHook = layout
  , XMonad.manageHook = myManageHook
  , XMonad.startupHook = myStartupHook (null args)
  }


main = do
  args <- getArgs
  n <- countScreens
  xmprocs <- mapM (\i -> spawnPipe ("xmobar -x" ++ show i)) [0 .. n - 1]
  xmonad (myConfig args) {
    logHook = mapM_
              (\handle -> dynamicLogWithPP $ myPP { ppOutput = System.IO.hPutStrLn handle })
              xmprocs
    }
