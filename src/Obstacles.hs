----------
-- Obstacles.hs
-- Placement des obstacles
----------

module Obstacles (
    placeObstacles
) where

import Random
import Types

-- Environ une case sur 30 est un obstacle
obstacleCount :: Configuration -> Int
obstacleCount config = (configWidth config * configHeight config) `div` 30

-- Obstacles randoms une fois en début de partie
placeObstacles :: GameState -> GameState
placeObstacles state
    | configMode config /= Obstacles = state
    | otherwise = placeMany (obstacleCount config) state
    where
        config = stateConfig state

        -- Ligne de départ du serpent est libre
        startRow = case stateSnake state of
            [] -> -1
            ((_, y) : _) -> y -- ligne de départ ou y a la tête

        -- Place n obstacles randomdans les cases libres
        placeMany 0 s = s 
        placeMany n s = case freeCells s of
            [] -> s
            cells -> placeMany (n - 1) (placeOne cells s)

        -- Place un obstacle dans une case libre aléatoire
        placeOne cells s = s { stateObstacles = cells !! index : stateObstacles s, stateSeed = newSeed }
            where
                (index, newSeed) = randomInt (length cells) (stateSeed s)

        -- Liste des cases libres
        freeCells s = [ (x, y) | y <- [0 .. configHeight config - 1],
                                 y /= startRow,
                                 x <- [0 .. configWidth config - 1],
                                 (x, y) `notElem` stateObstacles s ]
