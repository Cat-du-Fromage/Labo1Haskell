# Labo1 Haskell - Snake

## Description
C'est un jeu snake en mode terminal. Le jeu permet à un utilisateur de contrôler un serpent qui se déplace sur une grille, manger un objet fait grandir le serpent et permet de gagner des points. Il faut éviter les murs afin de ne pas mourir.

Problèmes que ce labo résoud :
1. Démontrer une architecture fonctionnelle propre à Haskell. La logique du jeu est séparée de la couche I/O.
2. Version moderne et configurable du jeu orinal Snake, jouable entièrement dans la console
3. Problématique du rafraîchissement de l'écran de la console

## Fonctionnalités

### Fonctionnalités de base
- Grille configurable, hauteur et largeur
- Déplacement du serpent, haut, droite, bas, gauche.
- Apparition aléatoire d'onjets à consommer.
- Croissance du serpent lorsqu'il mange.
- Détection des collisions, les 4 murs.
- Affichage du score courant
- Affichage du temps de la partie
- Écran de fin / Rejouer
- Leaderboard ? (non)

### Fonctionnalités en plus
- Choix du mode de jeu
    - Classique
    - Wrapping du terrain (passage d'un bout a l'autre du terrain)
    - Apparition d'objets sur la grille comme obstacle ?
- Changement de la vitesse du serpent (--speed)
- Lancer une partie avec tous les paramètres définis (--seed/--file) ? (si le temps)
- Tests unitaires
- Gestion des erreurs

## Example

### Partie classique
Dans la console :
```bash
snake --width 20 --height 6 --speed 10
```

Sortie :
```bash
┌────────────────────┐
│                    │
│              x     │
│                    │
│         ----->     │
│                    │
│                    │
└────────────────────┘
Score: 30  Temps: 146s
```
Le `x` représente l'objet à manger, le serpent est constitué de `-, |` pour le corps et de `<,>, v, ^` pour la tête.

### Partie custom
Dans la console :
```bash
snake --width 20 --height 20 --speed 10 --mode obstacle
```

Sortie :
```bash
┌────────────────────┐
│                    │
│      O       x     │
│                    │
│         ----->     │
│    O               │
│                O   │
└────────────────────┘
Score: 30  Temps: 146s
```
Les `O` représentes les obstacles à éviter.

### Partie avec fichier des paramètres
Dans la console :
```bash
snake --file levels/level1.txt
```

Example de fichier:
```text
width 25
height 15
mode obstacles
```

### Aide
Dans la console :
```bash
snake --help
Un jeu Snake en terminal

Utilisation: snake [OPTIONS]

Options:
--width INT   Largeur de la grille (défaut : 20)
--height INT  Hauteur de la grille (défaut : 15)
--speed INT   Vitesse du serpent (défaut : 5)
--mode MODE   Classic | infini | obstacles (défaut : classic)
--file FILE   Charger un niveau depuis un fichier
--help        Afficher cette aide
```