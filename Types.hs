----------
-- Types.hs
-- Définitions des type du jeu
----------

module Types (
    Position,
    Snake,
    Direction(..),
    Mode(..),
    Status(..),
    Configuration(..),
    GameState(..)
) where

import Random (Seed)

type Position = (Int, Int)

data Direction = Up | Right' | Down | Left'
    deriving (Show, Eq)

data Mode = Classic | Wrap | Obstacles
    deriving (Show, Eq)

data Status = Running | Paused | GameOver
    deriving (Show, Eq)

type Snake = [Position]

data GameState = GameState
    {
        stateConfig :: Configuration,
        stateSnake :: Snake,
        stateDirection :: Direction,
        stateStatus :: Status,
        stateApple :: Position,
        stateSeed :: Seed,
        stateScore :: Int
        -- TODO, ajouter mur, etc.
    }
    deriving Show

data Configuration = Configuration
    {
        -- Préfix, sinon on comprends pas d'ou ça vient dans les autres fichiers
        configWidth :: Int,
        configHeight :: Int,
        configSpeed :: Int,
        configMode :: Mode
    }
    deriving Show
