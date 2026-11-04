----------
-- Main.hs
-- Couche I/O
----------
module Main (main) where

import System.IO

import Screen
import Types

----------
-- Point d'entrée
----------

-- TODO completer
main :: IO()
main = do
    setupTerminal
    draw (renderTerrain terrainWidth terrainHeight)
    resetTerminal

----------------------------------------------------

--------
-- Boucle principale
--------

-- TODO gérer un état du jeu
-- gameLoop :: ??? -> IO()

-- TODO pareil, état du jeu ?
-- replay :: ??? -> IO()

----------------------------------------------------

--------
-- Touches
--------

readKeys :: IO[Char]
readKeys = do
    -- https://hackage-content.haskell.org/package/base-4.22.0.0/docs/System-IO.html#v:hReady
    -- retourne True si au moins un item est prêt à être manipulé
    isReady <- hReady stdin
    if isReady then
        do
            c <- getChar
            more <- readKeys
            return (c:more)
    else
        return []

mapKeysToDirection :: Char -> Maybe Direction
mapKeysToDirection c
    -- gère les clavier wasd et zqsd
    | c `elem` "wz" = Just Up
    | c `elem` "d" = Just Right'
    | c `elem` "s" = Just Down
    | c `elem` "aq" = Just Left'
    | otherwise = Nothing
