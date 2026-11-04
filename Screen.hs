----------
-- Screen.hs
-- Affichage dans le terminal
----------
module Screen (terrainWidth, terrainHeight, renderTerrain, setupTerminal, draw, resetTerminal) where

import System.IO

-- shortcut: taille fixe, à remplacer par --width et --height quand les arguments seront lus
terrainWidth :: Int
terrainWidth = 20

terrainHeight :: Int
terrainHeight = 6

renderTerrain :: Int -> Int -> String
renderTerrain width height = unlines ([top] ++ rows ++ [bottom])
    where
        top = "┌" ++ replicate width '─' ++ "┐"
        bottom = "└" ++ replicate width '─' ++ "┘"
        rows = replicate height ("│" ++ replicate width ' ' ++ "│")

-- Efface l'écran une seule fois et cache le curseur
setupTerminal :: IO()
setupTerminal = do
    -- Sans UTF-8, les caractères du cadre font planter putStr sous Windows
    hSetEncoding stdout utf8
    hSetBuffering stdout (BlockBuffering Nothing)
    putStr "\ESC[2J\ESC[?25l"

-- Réécrit par-dessus l'image précédente, effacer à chaque tick ferait clignoter l'écran
draw :: String -> IO()
draw frame = do
    putStr ("\ESC[H" ++ frame)
    hFlush stdout

-- Réaffiche le curseur, à appeler avant de quitter
resetTerminal :: IO()
resetTerminal = do
    putStr "\ESC[?25h"
    hFlush stdout
