----------
-- Random.hs
-- Générateur pseudo-aléatoire pur (le package random n'est pas fourni avec GHC)
----------

module Random (
    Seed,
    nextSeed,
    randomInt
) where

-- La graine est passée d'un état à l'autre, aucune variable cachée
type Seed = Int

-- Générateur congruentiel linéaire : constantes de la libc (glibc rand)
nextSeed :: Seed -> Seed
nextSeed s = (1103515245 * s + 12345) `mod` 2147483648

-- Entier dans [0, n - 1] et la graine suivante
-- Les bits de poids faible d'un LCG sont peu aléatoires, on les ignore avec div
randomInt :: Int -> Seed -> (Int, Seed)
randomInt n s = ((s' `div` 65536) `mod` n, s')
    where
        s' = nextSeed s
