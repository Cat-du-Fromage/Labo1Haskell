----------
-- Screen.hs
-- Affichage dans le terminal
----------
module Screen (
    renderGame,
    setupEncoding,
    setupTerminal,
    draw,
    resetTerminal
) where

import Control.Monad (when)
import System.Info (os)
import System.IO
import System.Process (callCommand)

import Types

renderGame :: GameState -> String
renderGame state = unlines ([top] ++ rows ++ [bottom, info] ++ message)
    where
        width = configWidth (stateConfig state)
        height = configHeight (stateConfig state)
        top = "┌" ++ replicate width '─' ++ "┐"
        bottom = "└" ++ replicate width '─' ++ "┘"

        -- Une ligne par y et une case par x
        rows = [ "│" ++ [ charInCell state (x, y) | x <- [0 .. width - 1] ] ++ "│"
               | y <- [0 .. height - 1] ]

        -- shortcut: speed ticks = 1 seconde, ignore le temps d'affichage ; lire l'horloge si l'écart gêne
        seconds = stateTicks state `div` configSpeed (stateConfig state)

        info = "Score: " ++ show (stateScore state) ++ "  Temps: " ++ show seconds ++ "s"
            ++ "   (wasd: bouger, p: pause, x: quitter)"

        message = case stateStatus state of
            Running -> []
            Paused -> ["PAUSE"]
            GameOver -> ["GAME OVER | r: rejouer, x: quitter"]

charInCell :: GameState -> Position -> Char
charInCell state pos =
    case lookup pos (snakeCells state) of
        Just c -> c
        Nothing
            | pos == stateApple state -> 'x'
            | pos `elem` stateObstacles state -> 'O'
            | otherwise -> ' '

-- Chaque case du serpent est associée à son caractère
snakeCells :: GameState -> [(Position, Char)]
snakeCells state = case stateSnake state of
    [] -> []
    snake@(snakeHead : _) ->
        (snakeHead, headChar (stateDirection state)) : zipWith bodyPart snake (drop 1 snake)
    where
        bodyPart (_, previousY) (x, y)
            | previousY == y = ((x, y), '-')
            | otherwise = ((x, y), '|')

-- La tête va dans la direction du mouvement
headChar :: Direction -> Char
headChar Up = '^'
headChar Right' = '>'
headChar Down = 'v'
headChar Left' = '<'

-- À appeler en premier : l'aide et les erreurs ont aussi des accents
setupEncoding :: IO()
setupEncoding = do
    -- La console Windows décode en page 850 par défaut (le Mac est déjà en UTF-8)
    when (os == "mingw32") (callCommand "chcp 65001 > nul")
    -- Sans UTF-8, les caractères du cadre font planter putStr sous Windows
    hSetEncoding stdout utf8
    hSetEncoding stderr utf8

-- Efface l'écran une seule fois et cache le curseur
setupTerminal :: IO()
setupTerminal = do
    hSetBuffering stdout (BlockBuffering Nothing)
    hSetBuffering stdin NoBuffering -- ne pas attendre Entrée + ne pas afficher lettre sur jeu
    hSetEcho stdin False
    putStr "\ESC[2J\ESC[?25l"

-- Réécrit par-dessus l'image précédente, effacer à chaque tick ferait clignoter l'écran
draw :: String -> IO()
draw frame = do
    putStr ("\ESC[H" ++ frame ++ "\ESC[J")
    hFlush stdout

-- Réaffiche le curseur, à appeler avant de quitter
resetTerminal :: IO()
resetTerminal = do
    hSetEcho stdin True
    hSetBuffering stdin LineBuffering
    putStr "\ESC[?25h"
    hFlush stdout
