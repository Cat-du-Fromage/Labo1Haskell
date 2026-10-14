
type Position = (Int, Int)

data Direction = Up | Right | Down | Left
    deriving (Show, Eq)

data Mode = Classic | Wrap | Obstacles
    deriving (Show, Eq)

data Status = Running | Paused | GameOver
    deriving (Show, Eq)

data Configuration = Configuration
    {
        width :: Int,
        height :: Int,
        speed :: Int,
        mode :: Mode
    }
    deriving Show