----------
-- Tests.hs
-- Tests unitaires de la logique pure
-- Aidé par Claude, je savais pas comment faire
-- Prompt utilisé : "Créer moi un fichier de test avec un exemple de test unitaire pour le serpent, donne moi aussi les explications nécessaires pour que je puisse en ajouter d'autres"
-- Lancer depuis la racine : runghc -isrc tests/Tests.hs
----------

module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)

import Apple
import Arguments
import Game
import Obstacles
import Random
import Snake
import Types

----------
-- Définition d'un test
----------

type Test = (String, Bool)

main :: IO ()
main = do
    let failures = [ name | (name, ok) <- allTests, not ok ]
    mapM_ (\name -> putStrLn ("ECHEC: " ++ name)) failures
    putStrLn (show (length allTests - length failures) ++ "/" ++ show (length allTests) ++ " tests réussis")
    unless (null failures) exitFailure

allTests :: [Test]
allTests = snakeTests ++ gameTests ++ appleTests ++ obstacleTests ++ argumentTests ++ randomTests

----------------------------------------------------

----------
-- Données
----------

config :: Mode -> Configuration
config mode = Configuration
    {
        configWidth = 10,
        configHeight = 5,
        configSpeed = 5,
        configMode = mode
    }

-- tête du serpent en (5, 2), pomme loin, pas d'obstacle
baseState :: Mode -> GameState
baseState mode = (initState (config mode) 42)
    {
        stateSnake = [(5, 2), (4, 2), (3, 2)],
        stateDirection = Right',
        stateApple = (0, 0),
        stateObstacles = []
    }

-- Tête touche le bord droit
atRightBorder :: Mode -> GameState
atRightBorder mode = (baseState mode) { stateSnake = [(9, 2), (8, 2), (7, 2)] }

----------------------------------------------------

----------
-- Snake
----------

snakeTests :: [Test]
snakeTests =
    [
        ("newPos Up", newPos Up (3, 3) == (3, 2)),
        ("newPos Right'", newPos Right' (3, 3) == (4, 3)),
        ("newPos Down", newPos Down (3, 3) == (3, 4)),
        ("newPos Left'", newPos Left' (3, 3) == (2, 3)),
        ("opposite deux fois = identité", all (\d -> opposite (opposite d) == d) [Up, Right', Down, Left']),
        ("initSnake au centre, 3 cases", initSnake (config Classic) == [(5, 2), (4, 2), (3, 2)]),
        ("moveSnake sans manger garde la longueur",
            moveSnake False (6, 2) [(5, 2), (4, 2), (3, 2)] == [(6, 2), (5, 2), (4, 2)]),
        ("moveSnake en mangeant grandit d'une case",
            moveSnake True (6, 2) [(5, 2), (4, 2), (3, 2)] == [(6, 2), (5, 2), (4, 2), (3, 2)]),
        ("la queue reste si on grandit", bitesSelf True (3, 2) [(5, 2), (4, 2), (3, 2)]),
        ("le corps tue", bitesSelf False (4, 2) [(5, 2), (4, 2), (3, 2)])
    ]

----------------------------------------------------

----------
-- Game
----------

gameTests :: [Test]
gameTests =
    [
        ("step avance la tête", take 1 (stateSnake (step (baseState Classic))) == [(6, 2)]),
        ("step compte les ticks", stateTicks (step (baseState Classic)) == 1),
        ("mode classic: le mur tue", stateStatus (step (atRightBorder Classic)) == GameOver),
        ("mode obstacles: le mur tue", stateStatus (step (atRightBorder Obstacles)) == GameOver),
        ("mode wrap: ressort de l'autre côté", take 1 (stateSnake (step (atRightBorder Wrap))) == [(0, 2)]),
        ("obstacle tue", stateStatus (step (baseState Obstacles) { stateObstacles = [(6, 2)] }) == GameOver),
        ("manger: +10 points", stateScore (step eating) == 10),
        ("manger: le serpent grandit", length (stateSnake (step eating)) == 4),
        ("manger: nouvelle pomme", stateApple (step eating) `notElem` stateSnake (step eating)),
        ("pas de demi-tour", stateDirection (changeDirection Left' (baseState Classic)) == Right'),
        ("changement de direction", stateDirection (changeDirection Up (baseState Classic)) == Up),
        ("en pause, step ne fait rien", stateSnake (step paused) == stateSnake paused),
        ("en pause, pas de changement de direction", stateDirection (changeDirection Up paused) == Right'),
        ("pause puis reprise", stateStatus (togglePause paused) == Running),
        ("pas de pause après game over", stateStatus (togglePause over) == GameOver)
    ]
    where
        eating = (baseState Classic) { stateApple = (6, 2) }
        paused = togglePause (baseState Classic)
        over = (baseState Classic) { stateStatus = GameOver }

----------------------------------------------------

----------
-- Apple
----------

appleTests :: [Test]
appleTests =
    [
        ("pomme dans la grille", not (isOutside (config Classic) (stateApple placed))),
        ("pomme hors du serpent", stateApple placed `notElem` stateSnake placed),
        ("pomme hors des obstacles", stateApple placed `notElem` stateObstacles placed),
        ("grille pleine = fin de partie", stateStatus (placeApple full) == GameOver)
    ]
    where
        -- Une seule case libre : (9, 4)
        blocked = [ (x, y) | y <- [0 .. 4], x <- [0 .. 9], (x, y) /= (9, 4) ]
        placed = placeApple (baseState Obstacles) { stateObstacles = drop 3 blocked, stateSnake = take 3 blocked }
        full = (baseState Classic) { stateSnake = [ (x, y) | y <- [0 .. 4], x <- [0 .. 9] ] }

----------------------------------------------------

----------
-- Obstacles
----------

obstacleTests :: [Test]
obstacleTests =
    [
        ("mode classic: aucun obstacle", null (stateObstacles (initState (config Classic) 42))),
        ("mode obstacles: 1 case sur 30", length (stateObstacles largeGrid) == (20 * 15) `div` 30),
        ("mode obstacles: ligne de départ libre", all (\(_, y) -> y /= 7) (stateObstacles largeGrid)),
        ("mode obstacles: hors du serpent", all (`notElem` stateSnake largeGrid) (stateObstacles largeGrid)),
        ("mode obstacles: grille trop petite = aucun", null (stateObstacles (placeObstacles smallGrid)))
    ]
    where
        largeGrid = initState (Configuration 20 15 5 Obstacles) 42
        -- 5 x 3 = 15 cases, moins de 30
        smallGrid = (initState (Configuration 5 3 5 Obstacles) 42) { stateObstacles = [] }

----------------------------------------------------

----------
-- Arguments
----------

argumentTests :: [Test]
argumentTests =
    [
        ("sans argument: valeurs par défaut", isPlay (\c -> configWidth c == 20 && configHeight c == 15
                                                           && configSpeed c == 5 && configMode c == Classic) []),
        ("--width et --mode", isPlay (\c -> configWidth c == 30 && configMode c == Obstacles)
                                     ["--width", "30", "--mode", "obstacles"]),
        ("--help", isHelp (parseArgs ["--width", "30", "--help"])),
        ("entier invalide", isError (parseArgs ["--speed", "rapide"])),
        ("option inconnue", isError (parseArgs ["--foo", "1"])),
        ("valeur manquante", isError (parseArgs ["--width"])),
        ("mode inconnu", isError (parseArgs ["--mode", "hard"])),
        ("largeur trop petite", isError (parseArgs ["--width", "4"])),
        ("vitesse nulle", isError (parseArgs ["--speed", "0"]))
    ]
    where
        isPlay check args = case parseArgs args of
            Right (Play c) -> check c
            _ -> False
        isHelp (Right Help) = True
        isHelp _ = False
        isError (Left _) = True
        isError _ = False

----------------------------------------------------

----------
-- Random
----------

randomTests :: [Test]
randomTests =
    [
        ("randomInt dans [0, n - 1]", all (\v -> v >= 0 && v < 7) values),
        ("même graine = même tirage", fst (randomInt 100 42) == fst (randomInt 100 42)),
        ("la graine avance", snd (randomInt 100 42) /= 42)
    ]
    where
        values = take 1000 (map fst (drop 1 (iterate (\(_, s) -> randomInt 7 s) (0, 1))))
