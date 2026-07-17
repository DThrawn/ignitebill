# Walkthrough - Release de l'APK sur GitHub

J'ai généré une nouvelle version de l'application et je l'ai publiée sur le dépôt GitHub.

## Changements effectués

### Build & Release
- **Compilation de l'APK** : Utilisation de `flutter build apk --release` pour générer une version optimisée.
- **Mise à jour du dossier de release** : L'APK a été déplacé dans le dossier [github_apks/app-release.apk](file:///home/darwin/StudioProjects/timer/github_apks/app-release.apk).
- **Push sur GitHub** : Les modifications (y compris l'APK) ont été poussées sur la branche `main`.

### Mises à jour de configuration (Nécessaires pour le build)
Pour permettre la compilation réussie, j'ai également appliqué les mises à jour suivantes :
- **AGP** : Passage à `8.11.2`.
- **Kotlin** : Passage à `2.2.20`.
- **Gradle** : Passage à `8.14.5`.
- **Target SDK** : Mise à jour vers `36`.

## Vérification

### Statut du Dépôt
Le dernier commit sur GitHub contient l'APK mis à jour :
- **Commit** : `6b50a9c`
- **Message** : `chore: build and update release APK for v1.0.1+2`

L'APK est maintenant accessible directement via le lien suivant sur GitHub :
`https://github.com/DThrawn/ignitebill/raw/main/github_apks/app-release.apk`

> [!WARNING]
> L'APK pèse environ 55 Mo, ce qui dépasse légèrement la recommandation de GitHub (50 Mo), mais le transfert a réussi.
