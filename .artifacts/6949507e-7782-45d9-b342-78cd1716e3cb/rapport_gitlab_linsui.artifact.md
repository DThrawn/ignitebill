# Rapport des commentaires de Linsui sur GitLab

Ce rapport résume les interactions et les demandes formulées par **linsui** (@linsui), mainteneur F-Droid, concernant la soumission de l'application **IgniteBill** sur le dépôt officiel F-Droid.

## Informations Générales
- **Utilisateur ciblé :** linsui (@linsui)
- **Projet concerné :** [fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata)
- **Merge Requests analysées :**
    - [!44356](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/44356) (Ouverte)
    - [!43250](https://gitlab.com/fdroid/fdroiddata/-/merge_requests/43250) (Fermée)

## Résumé des demandes de Linsui

### 1. Structure et Métadonnées
- **Ne pas inclure les fichiers de métadonnées** (résumé, description, images, etc.) directement dans le dépôt `fdroiddata`.
- **Utiliser la structure Fastlane** dans le dépôt source de l'application (en amont). F-Droid les récupérera automatiquement.
- **Utiliser des hashs de commit complets** au lieu de tags ou de noms de branches pour garantir la reproductibilité et la sécurité.

### 2. Configuration Build Flutter
- **Suivre le template officiel** pour les applications Flutter : `templates/build-flutter.yml`.
- **Fixer (pin) la version de Flutter** utilisée dans le dépôt et l'extraire dynamiquement lors du build.

### 3. Gestion des ABI (ABI Split)
Linsui a demandé la mise en place du "split APK" par architecture (ABI) pour réduire la taille des téléchargements.
- **Modifier le fichier `build.gradle`** pour inclure une logique de surcharge du `versionCode` :
  ```kotlin
  import com.android.build.gradle.internal.api.ApkVariantOutputImpl
  val abiCodes = mapOf("armeabi-v7a" to 1, "arm64-v8a" to 2, "x86_64" to 3)
  android.applicationVariants.configureEach {
      val variant = this
      variant.outputs.forEach { output ->
          val abiVersionCode = abiCodes[output.filters.find { it.filterType == "ABI" }?.identifier]
          if (abiVersionCode != null) {
              (output as ApkVariantOutputImpl).versionCodeOverride = variant.versionCode * 10 + abiVersionCode
          }
      }
  }
  ```
- **Mettre à jour les métadonnées** F-Droid pour supporter les différentes ABI.

### 4. Reproductibilité et Sécurité
- **Ajouter les champs `Binaries` ou `binary`** ainsi que `AllowedAPKSigningKeys` dans les métadonnées pour activer les "Reproducible Builds".
- **Sécuriser la clé de signature** et s'assurer d'en avoir une sauvegarde fiable.

## Statut de la soumission
La Merge Request actuelle (!44356) est en attente de réponse (`waiting-on-response`). Plusieurs commits ont été ajoutés par l'auteur (@DThrawn) pour tenter de répondre à ces exigences, notamment sur la découverte des APK et l'utilisation de Java 21.

---
*Note : Le jeton GitLab trouvé dans les remotes (`glpat-...`) a été utilisé pour extraire ces informations via l'API GitLab.*
