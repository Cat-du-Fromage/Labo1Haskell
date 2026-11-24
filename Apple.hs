----------
-- Apple.hs
-- Placement de la pomme
----------

module Apple (
    placeApple
) where

import Random
import Types

-- Pose la pomme sur une case libre au hasard
-- Plus aucune case libre = le serpent remplit la grille, la partie est finie
placeApple :: GameState -> GameState
placeApple state = case freeCells of
    [] -> state { stateStatus = GameOver }
    _ -> state { stateApple = freeCells !! index, stateSeed = newSeed }
    where
        config = stateConfig state
        freeCells = [ (x, y) | y <- [0 .. configHeight config - 1],
                               x <- [0 .. configWidth config - 1],
                               (x, y) `notElem` stateSnake state,
                               (x, y) `notElem` stateObstacles state ]
        (index, newSeed) = randomInt (length freeCells) (stateSeed state)
