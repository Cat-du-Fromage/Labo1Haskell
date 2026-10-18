----------
-- Game.hs
-- Logique du jeu
----------

module Game () where

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
isOutside config (x, y) =   x < 0 || y < 0 || x >= configWidth config || y >= configHeight config

----------------------------------------------------

----------
-- Gestion du temps ?
----------