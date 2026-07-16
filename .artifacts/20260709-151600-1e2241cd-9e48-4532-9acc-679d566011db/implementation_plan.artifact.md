# Implémentation de 4 Styles Visuels et Sélecteur de Thème

Ce plan détaille l'ajout de 4 styles graphiques distincts pour l'application IgniteBill, tout en maintenant les performances et en ajoutant un sélecteur dans les réglages.

## Changements Proposés

### [Gestion du Thème]

Mise en place d'un système de changement de thème dynamique sans redémarrage de l'application.

- Création d'un `ValueNotifier<int> themeNotifier` global pour piloter le style.
- Persistance du choix dans `SharedPreferences` sous la clé `appStyle`.

### [Styles Visuels]

Définition de 4 configurations `ThemeData` :
1.  **Style 0 : Premium Glow (Super Rendu)**
    - Couleurs : Indigo & Cyan.
    - Formes : Très arrondies (24px), ombres portées douces et colorées.
    - Boutons : Effet de lévitation.
2.  **Style 1 : Practical Clean (Pratique)**
    - Couleurs : Ardoise & Gris-Bleu.
    - Formes : Angles modérés (12px), contraste maximal pour la lecture.
    - Économie : Ombres minimales.
3.  **Style 2 : Organic Soft (Intermédiaire)**
    - Couleurs : Menthe & Sauge (Pastels).
    - Formes : Bulles "organiques" asymétriques.
4.  **Style 3 : Cyber Tech (Intermédiaire)**
    - Couleurs : Noir Profond & Orange Électrique.
    - Formes : Look "Squircle" (Apple style) et bordures lumineuses.

### [Interface Utilisateur]

#### [main.dart](file:///home/darwin/StudioProjects/timer/lib/main.dart)

- Ajout de la classe `AppStyle` pour centraliser les définitions de thèmes.
- Modification de `MonApplication` pour utiliser `ValueListenableBuilder`.
- Ajout du sélecteur dans le dialogue des paramètres globaux :
    - Une ligne grise discrète sous la section Sauvegarde.
    - 4 boutons circulaires (Pastilles de couleur) pour changer le style instantanément.
- Ajustement des widgets `Card` pour qu'ils héritent mieux du thème (suppression des couleurs codées en dur là où c'est possible).

## Plan de Vérification

### Tests Automatisés
- `flutter test` (si des tests existent déjà, pour vérifier la non-régression).

### Vérification Manuelle
- Ouverture des paramètres et test de chaque bouton de style.
- Vérification que le style est bien sauvegardé après fermeture et réouverture de l'application.
- Vérification du rendu en mode clair et mode sombre pour chaque style.
- Inspection visuelle de la "bulle" de session dans l'historique pour chaque thème.
