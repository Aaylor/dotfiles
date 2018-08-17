{-# OPTIONS_GHC -fno-warn-missing-signatures -fno-warn-orphans #-}
{-# LANGUAGE TypeFamilies #-}

import XMonad
import XMonad.Hooks.DynamicLog (PP(ppLayout, ppSort, ppTitle, ppTitleSanitize, ppVisible),
                                statusBar, wrap)
import XMonad.Hooks.ManageDocks(ToggleStruts(..), avoidStruts, manageDocks)
import XMonad.Hooks.ManageHelpers
import qualified XMonad.StackSet as W
import XMonad.Util.WorkspaceCompare (getSortByXineramaRule)

import qualified Data.Map as M
import System.Exit



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
    tiled = Tall masterPanes delta ratio
    -- Default number of windows in the master pane
    masterPanes = 1
    -- Default proportion of screen occupied by mater pane
    ratio = 1 / 2
    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100




------------------------------------------------------------------------
-- Workspaces:

-- | The list of workspaces.
-- The number of workspaces is determined by the lenght of this list

workspaces :: [WorkspaceId]
workspaces = [ "1"
             , "2"
             , "3"
             , "4"
             , "5"
             , "6"
             , "7"
             , "8"
             , "9" ]


------------------------------------------------------------------------
-- Configuration:

-- | Modifier
myModMask :: KeyMask
myModMask = mod4Mask

-- | Width of the border
borderWidth :: Dimension
borderWidth = 1

-- | Border color for (un)focused windows.
normalBorderColor, focusedBorderColor :: String
normalBorderColor = "gray"
focusedBorderColor = "red"

-- | Terminal
terminal :: String
terminal = "konsole"



------------------------------------------------------------------------
-- Hooks:

myManageHook =
  manageDocks <+>
  manageHook XMonad.def <+>
  composeOne [ isDialog -?> doFloat
             , transience]



------------------------------------------------------------------------
-- Key bindings:

keys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
keys conf @ (XConfig { XMonad.modMask = modMask }) =
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

   -- Quit/Restart
 , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))
 , ((modMask, xK_q), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi")
 ]
  ++
  -- mod-[1 .. 9]: switch to workspace N
  -- mod-shift-[1 .. 9]: switch application to workspace N
  [ ((modMask .|. m, k), windows $ f i)
  | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
  , (f, m) <- [ (W.greedyView, 0), (W.shift, shiftMask) ] ]

  ++
  -- mod-[a,z,e]: Switch to screen 1/2/3
  -- mod-shift-[a,z,e]: Move to screen 1/2/3
  [ ((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
  | (key, sc) <- zip [ xK_a, xK_z, xK_e ] [ 0 .. ]
  , (f, m) <- [ (W.view, 0), (W.shift, shiftMask) ] ]



------------------------------------------------------------------------
-- Main:

myPP =
  def
  { ppLayout = const ""
  , ppSort = getSortByXineramaRule
  , ppTitle = const ""
  , ppTitleSanitize = const ""
  , ppVisible = wrap "(" ")" }

toggleStrutsKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)

myConfig =
  XMonad.def
  { XMonad.borderWidth = Main.borderWidth
  , XMonad.workspaces = Main.workspaces
  , XMonad.normalBorderColor = Main.normalBorderColor
  , XMonad.focusedBorderColor = Main.focusedBorderColor
  , XMonad.terminal = Main.terminal
  , XMonad.modMask = Main.myModMask
  , XMonad.keys = Main.keys
    -- Hooks
  , XMonad.layoutHook = Main.layout
  , XMonad.manageHook = Main.myManageHook }


main = xmonad =<< statusBar "xmobar" myPP toggleStrutsKey myConfig
