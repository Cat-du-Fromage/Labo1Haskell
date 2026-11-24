{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}
----------
-- Keyboard.hs
-- Lecture d'une touche sans attendre Entrée, sur Mac/Linux et Windows
----------

module Keyboard (
    keyReady,
    readKey
) where

#if defined(mingw32_HOST_OS)
import Foreign.C.Types (CInt(..))

-- Sous Windows, GHC ignore NoBuffering : getChar attend Entrée et le jeu se fige.
-- On passe donc par les fonctions console de la libc Windows (conio.h).
foreign import ccall unsafe "conio.h _kbhit" c_kbhit :: IO CInt
foreign import ccall unsafe "conio.h _getch" c_getch :: IO CInt

-- True si une touche attend d'être lue
keyReady :: IO Bool
keyReady = do
    n <- c_kbhit
    return (n /= 0)

-- Lit une touche (bloquant), sans écho
readKey :: IO Char
readKey = do
    c <- c_getch
    return (toEnum (fromIntegral c))
#else
import System.IO (hReady, stdin)

-- True si une touche attend d'être lue
keyReady :: IO Bool
keyReady = hReady stdin

-- Lit une touche (bloquant), l'écho est coupé dans setupTerminal
readKey :: IO Char
readKey = getChar
#endif
