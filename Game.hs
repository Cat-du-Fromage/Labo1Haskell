----------
-- Game.hs
-- Logique du jeu
----------

module Game (
    newPos,
    isOutside,
    initState,
    changeDirection,
    togglePause,
    moveSnake,
    step
) where

import Apple
import Random (Seed)
import Types

----------
-- Deplacements
----------

-- Si on part du principe que (0, 0) est en haut à gauche
newPos :: Direction -> Position -> Position
newPos Up (x, y) = (x, y - 1)
newPos Right' (x, y) = (x + 1, y)
newPos Down (x, y) = (x, y + 1)
newPos Left' (x, y) = (x - 1, y)

isOutside :: Configuration -> Position -> Bool
isOutside config (x, y) = x < 0 || y < 0 || x >= configWidth config || y >= configHeight config

opposite :: Direction -> Direction
opposite Up = Down
opposite Right' = Left'
opposite Down = Up
opposite Left' = Right'

-- Pour le mode wrap, si on sort d'un côté on revient de l'autre
-- sortir à gauche ramène à droite, etc.
wrapPosition :: Configuration -> Position -> Position
wrapPosition config (x, y) = (x `mod` configWidth config, y `mod` configHeight config)

-- Déplacement du serpent
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

-- Calcule l'état suivant à partir de l'état courant -> représente un tick de jeu
step :: GameState -> GameState
step state
    -- En pause ou fini
    | stateStatus state /= Running = state
    | otherwise = case stateSnake state of
        [] -> state
        (snakeHead : _) -> moveFrom snakeHead
    where
        config = stateConfig state
        snake = stateSnake state

        moveFrom snakeHead
            | hitsBorder || bitesSelf = state { stateStatus = GameOver }
            | isGrowing = placeApple movedState { stateScore = stateScore state + applePoints }
            | otherwise = movedState
            where
                targetPos = newPos (stateDirection state) snakeHead

                target
                    | configMode config == Wrap = wrapPosition config targetPos
                    | otherwise = targetPos

                hitsBorder = configMode config /= Wrap && isOutside config target

                bitesSelf
                    | isGrowing = target `elem` snake
                    | otherwise = target `elem` dropLast snake

                movedState = state { stateSnake = moveSnake isGrowing target snake }

                isGrowing = target == stateApple state

----------------------------------------------------

----------
-- Création du serpent
----------

baseLength :: Int
baseLength = 3

-- Points gagnés par pomme mangée
applePoints :: Int
applePoints = 10

-- horizontal au milieu du terrain, tête à droite.
-- Ex:  cx = 10 et cy = 3 -> [(10,3), (9,3), (8,3)]
initSnake :: Configuration -> Snake
initSnake config = [ (cx - i, cy) | i <- [0 .. baseLength - 1] ]
    where
        cx = configWidth config `div` 2
        cy = configHeight config `div` 2

initState :: Configuration -> Seed -> GameState
initState config seed = placeApple GameState
    {
        stateConfig = config,
        stateSnake = initSnake config,
        stateDirection = Right',
        stateStatus = Running,
        stateApple = (-1, -1), -- remplacée tout de suite par placeApple
        stateSeed = seed,
        stateScore = 0
        -- TODO init murs
    }

----------------------------------------------------

----------
-- Commandes
----------

changeDirection :: Direction -> GameState -> GameState
changeDirection newDirection state
    | stateStatus state /= Running = state
    | newDirection == opposite (stateDirection state) = state -- pas de demi tour direct
    | otherwise = state { stateDirection = newDirection } -- On crée une copie de state, on change un seul champ

togglePause :: GameState -> GameState
togglePause state = case stateStatus state of
    Running -> state { stateStatus = Paused }
    Paused -> state { stateStatus = Running }
    GameOver -> state


----------------------------------------------------

----------
-- Gestion du temps ?
----------
