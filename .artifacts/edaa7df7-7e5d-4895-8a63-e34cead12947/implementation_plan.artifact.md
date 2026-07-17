# Fix GitHub Build - Stability & Release Angle

Le build GitHub Actions échoue probablement à cause d'incompatibilités de versions (Kotlin 2.2 vs Gradle 8.14 vs Java 17) ou de paramètres de commande incorrects. Nous allons changer d'approche en stabilisant les versions sur des bases éprouvées et en améliorant le workflow pour créer une véritable "Release" GitHub.

## Changements Proposés

### 1. Stabilisation du projet (Android)
Nous allons utiliser des versions stables et cohérentes entre elles.
- **Gradle** : Passage à `8.10.2` (stable).
- **AGP (Android Gradle Plugin)** : Passage à `8.7.3` (stable).
- **Kotlin** : Passage à `2.1.0` (stable).
- **SDK Android** : Utilisation de l'API `35` (Android 15) au lieu de `36` (trop récent/instable).

### 2. Amélioration du Workflow GitHub (`.github/workflows/build.yml`)
- **Java 21** : Mise à jour de Java 17 vers Java 21 (requis pour les versions récentes d'AGP/Gradle).
- **Correction des flags** : Suppression du flag `--no-shrink` qui n'est pas supporté par `flutter build apk` et peut causer des erreurs.
- **Création d'une Release** : Ajout d'une étape pour créer automatiquement une "Release" sur GitHub et y attacher l'APK, au lieu de simplement l'uploader en tant qu'artéfact caché.

### Fichiers à modifier :
#### [MODIFY] [build.gradle.kts](file:///home/darwin/StudioProjects/timer/android/app/build.gradle.kts)
- Update `compileSdk` and `targetSdk` to `35`.

#### [MODIFY] [settings.gradle.kts](file:///home/darwin/StudioProjects/timer/android/settings.gradle.kts)
- Update AGP to `8.7.3`.
- Update Kotlin to `2.1.0`.

#### [MODIFY] [gradle-wrapper.properties](file:///home/darwin/StudioProjects/timer/android/gradle/wrapper/gradle-wrapper.properties)
- Update Gradle to `8.10.2`.

#### [MODIFY] [build.yml](file:///home/darwin/StudioProjects/timer/.github/workflows/build.yml)
- Update Java to `21`.
- Clean up build commands.
- Add Release step.

## Plan de Vérification
1.  **Build Local** : Tenter un build local (après avoir corrigé les variables d'environnement si nécessaire).
2.  **Push & Monitor** : Pousser les changements et vérifier le statut du workflow sur GitHub.
