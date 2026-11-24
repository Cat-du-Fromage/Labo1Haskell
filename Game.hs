----------
-- Game.hs
-- Logique du jeu
----------

module Game (
    isOutside,
    initState,
    changeDirection,
    togglePause,
    step
) where

import Apple
import Obstacles
import Random (Seed)
import Snake
import Types

----------
-- Grille
----------

isOutside :: Configuration -> Position -> Bool
isOutside config (x, y) = x < 0 || y < 0 || x >= configWidth config || y >= configHeight config

-- Pour le mode wrap, si on sort d'un côté on revient de l'autre
-- sortir à gauche ramène à droite, etc.
wrapPosition :: Configuration -> Position -> Position
wrapPosition config (x, y) = (x `mod` configWidth config, y `mod` configHeight config)

----------------------------------------------------

----------
-- Tick
----------

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
            | hitsBorder || hitsObstacle || bitesSelf isGrowing target snake = state { stateStatus = GameOver }
            | isGrowing = placeApple movedState { stateScore = stateScore state + applePoints }
            | otherwise = movedState
            where
                targetPos = newPos (stateDirection state) snakeHead

                target
                    | configMode config == Wrap = wrapPosition config targetPos
                    | otherwise = targetPos

                hitsBorder = configMode config /= Wrap && isOutside config target

                hitsObstacle = target `elem` stateObstacles state

                -- Seuls les vrais déplacements comptent : la pause n'avance pas le temps
                movedState = state { stateSnake = moveSnake isGrowing target snake,
                                     stateTicks = stateTicks state + 1 }

                isGrowing = target == stateApple state

----------------------------------------------------

----------
-- Création de la partie
----------

-- Points gagnés par pomme mangée
applePoints :: Int
applePoints = 10

initState :: Configuration -> Seed -> GameState
-- Les obstacles en premier évite que la pomme spawn dessus
initState config seed = placeApple (placeObstacles GameState
    {
        stateConfig = config,
        stateSnake = initSnake config,
        stateDirection = Right',
        stateStatus = Running,
        stateApple = (-1, -1), -- remplacée tout de suite par placeApple
        stateSeed = seed,
        stateScore = 0,
        stateTicks = 0,
        stateObstacles = []
    })

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
