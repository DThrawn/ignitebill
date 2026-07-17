# Build APKs based on GitHub Workflow

The goal is to build the Android APKs (Debug and Release) locally, following the steps defined in the `.github/workflows/build.yml` file.

## Proposed Changes

No source code changes will be made. The following commands will be executed in sequence:

1.  **Install dependencies**: `flutter pub get`
2.  **Build Debug APK**: `flutter build apk --debug --verbose`
3.  **Build Release APK**: `flutter build apk --release --no-shrink --verbose`

## Verification Plan

### Manual Verification
- Verify that `build/app/outputs/flutter-apk/app-debug.apk` is created.
- Verify that `build/app/outputs/flutter-apk/app-release.apk` is created.

> [!NOTE]
> Since `flutter` and `java` are not in the default PATH, I will use their full paths or ensure environment variables are set correctly during execution.
