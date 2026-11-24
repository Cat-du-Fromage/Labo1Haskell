----------
-- Snake.hs
-- Création et déplacement du serpent
----------

module Snake (
    initSnake,
    newPos,
    opposite,
    moveSnake,
    bitesSelf
) where

import Types

----------
-- Création
----------

baseLength :: Int
baseLength = 3

-- horizontal au milieu du terrain, tête à droite.
-- Ex:  cx = 10 et cy = 3 -> [(10,3), (9,3), (8,3)]
initSnake :: Configuration -> Snake
initSnake config = [ (cx - i, cy) | i <- [0 .. baseLength - 1] ]
    where
        cx = configWidth config `div` 2
        cy = configHeight config `div` 2

----------------------------------------------------

----------
-- Directions
----------

-- Si on part du principe que (0, 0) est en haut à gauche
newPos :: Direction -> Position -> Position
newPos Up (x, y) = (x, y - 1)
newPos Right' (x, y) = (x + 1, y)
newPos Down (x, y) = (x, y + 1)
newPos Left' (x, y) = (x - 1, y)

opposite :: Direction -> Direction
opposite Up = Down
opposite Right' = Left'
opposite Down = Up
opposite Left' = Right'

----------------------------------------------------

----------
-- Déplacement
----------

-- init crash sur une liste vide + généricité
dropLast :: [a] -> [a]
dropLast [] = []
dropLast [_] = []
dropLast (x : xs) = x : dropLast xs

-- On ajoute nouvelle tête devant + on retire le bout queue.
moveSnake :: Bool -> Position -> Snake -> Snake
moveSnake isGrowing newHeadPos snake
    | isGrowing = newHeadPos : snake
    | otherwise = newHeadPos : dropLast snake

-- La queue libère sa case au même tick, sauf si le serpent grandit
bitesSelf :: Bool -> Position -> Snake -> Bool
bitesSelf isGrowing target snake
    | isGrowing = target `elem` snake
    | otherwise = target `elem` dropLast snake
