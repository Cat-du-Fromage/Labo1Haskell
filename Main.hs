----------
-- Main.hs
-- Couche I/O
----------
module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Exception (finally)
import Data.Maybe (mapMaybe)
import Data.Time.Clock.POSIX (getPOSIXTime)

import Game
import Keyboard
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
            -- La seule source d'aléatoire : l'heure au lancement (en ms)
            time <- getPOSIXTime
            gameLoop (initState defaultConfiguration (floor (time * 1000)))

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
    c <- readKey
    case c of
        'r' -> gameLoop (initState (stateConfig state) (stateSeed state))
        'x' -> return ()
        _ -> replay state

----------------------------------------------------

--------
-- Touches
--------

readKeys :: IO[Char]
readKeys = do
    -- On vide toutes les touches en attente sans jamais bloquer
    isReady <- keyReady
    if isReady then
        do
            c <- readKey
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
