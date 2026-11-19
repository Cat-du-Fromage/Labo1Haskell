----------
-- Main.hs
-- Couche I/O
----------
module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Exception (finally)
import Data.Maybe (mapMaybe)
import System.IO

import Game
import Screen
import Types

----------
-- Point d'entrée
----------

-- TODO remplacer par la lecture des arguments pour --width etc.
defaultConfiguration :: Configuration
defaultConfiguration = Configuration
    {
        configWidth = terrainWidth,
        configHeight = terrainHeight,
        configSpeed = 5,
        configMode = Classic
    }

-- finally -> resetTerminal appelé même si le programme crash
-- https://hackage-content.haskell.org/package/base-4.22.0.0/docs/Control-Exception.html#v:finally
main :: IO()
main = finally game resetTerminal
    where
        game = do
            setupTerminal
            gameLoop (initState defaultConfiguration)

----------------------------------------------------

--------
-- Boucle principale
--------

gameLoop :: GameState -> IO()
gameLoop state = do
    draw (renderGame state)
    case stateStatus state of
        GameOver -> replay state
        _ -> do
            threadDelay (1000000 `div` configSpeed (stateConfig state))
            keys <- readKeys
            if 'x' `elem` keys
                then return ()
                else gameLoop (step (handleKeys keys state))

-- Écran de fin
replay :: GameState -> IO()
replay state = do
    c <- getChar
    case c of
        'r' -> gameLoop (initState (stateConfig state))
        'x' -> return ()
        _ -> replay state

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

handleKeys :: [Char] -> GameState -> GameState
handleKeys keys state = applyPause (applyDirection state)
    where
        directions = mapMaybe mapKeysToDirection keys

        applyDirection s = case reverse directions of
            [] -> s
            (lastDirection : _) -> changeDirection lastDirection s

        applyPause s
            | 'p' `elem` keys = togglePause s
            | otherwise = s
