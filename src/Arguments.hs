----------
-- Arguments.hs
-- Lecture des arguments de la ligne de commande (pur, l'IO reste dans Main)
----------

module Arguments (
    Command(..),
    parseArgs,
    usage
) where

import Text.Read (readMaybe)

import Types

-- Ce que l'utilisateur demande : jouer avec une configuration ou afficher l'aide
data Command = Play Configuration | Help
    deriving Show

defaultConfiguration :: Configuration
defaultConfiguration = Configuration
    {
        configWidth = 20,
        configHeight = 15,
        configSpeed = 5,
        configMode = Classic
    }

parseArgs :: [String] -> Either String Command
parseArgs args
    | "--help" `elem` args = Right Help
    | otherwise = case parseOptions args defaultConfiguration of
        Left err -> Left err
        Right config -> fmap Play (validate config)

-- Les options vont par paires : --option valeur
parseOptions :: [String] -> Configuration -> Either String Configuration
parseOptions [] config = Right config
parseOptions [flag] _ = Left ("valeur manquante pour " ++ flag)
parseOptions (flag : value : rest) config = case setOption flag value config of
    Left err -> Left err
    Right newConfig -> parseOptions rest newConfig

setOption :: String -> String -> Configuration -> Either String Configuration
setOption "--width" value config = fmap (\n -> config { configWidth = n }) (readInt "--width" value)
setOption "--height" value config = fmap (\n -> config { configHeight = n }) (readInt "--height" value)
setOption "--speed" value config = fmap (\n -> config { configSpeed = n }) (readInt "--speed" value)
setOption "--mode" value config = fmap (\m -> config { configMode = m }) (readMode value)
setOption flag _ _ = Left ("option inconnue : " ++ flag)

readInt :: String -> String -> Either String Int
readInt flag value = case readMaybe value of
    Just n -> Right n
    Nothing -> Left (flag ++ " attend un entier, reçu : " ++ value)

readMode :: String -> Either String Mode
readMode "classic" = Right Classic
readMode "wrap" = Right Wrap
readMode "obstacles" = Right Obstacles
readMode value = Left ("mode inconnu : " ++ value ++ " (classic | wrap | obstacles)")

-- Le serpent de départ fait 3 cases au centre, et speed divise une seconde
validate :: Configuration -> Either String Configuration
validate config
    | configWidth config < 5 = Left "--width doit valoir au moins 5"
    | configHeight config < 3 = Left "--height doit valoir au moins 3"
    | configSpeed config < 1 = Left "--speed doit valoir au moins 1"
    | otherwise = Right config

usage :: String
usage = unlines
    [
        "Snake",
        "",
        "Utilisation: snake [OPTIONS]",
        "",
        "Options:",
        "--width INT   Largeur de la grille (défaut : 20)",
        "--height INT  Hauteur de la grille (défaut : 15)",
        "--speed INT   Vitesse du serpent (défaut : 5)",
        "--mode MODE   classic | wrap | obstacles (défaut : classic)",
        "--help        Afficher cette aide"
    ]
