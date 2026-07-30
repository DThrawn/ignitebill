# Implementation Plan - Fix F-Droid Metadata and Build Errors

The project is currently failing F-Droid CI pipelines due to metadata formatting issues and a Gradle signing configuration error. This plan outlines the steps to canonicalize the metadata file and add a prebuild step to bypass the signing issue.

## User Review Required

> [!IMPORTANT]
> The build failure `SigningConfig with name 'release' not found` is caused by the app's `build.gradle.kts` referencing a `release` config that isn't defined or available in the CI environment. I will add a `sed` command to the metadata's `prebuild` section to strip this reference during the F-Droid build. This is a standard practice for F-Droid packaging.

## Proposed Changes

### F-Droid Metadata

#### [MODIFY] [com.dthrawn.ignitebill.yml](file:///home/darwin/StudioProjects/timer/metadata/com.dthrawn.ignitebill.yml)
- Add `AutoName: IgniteBill` to comply with F-Droid requirements.
- Reformat `Binaries` to the canonical multi-line format.
- Move `AllowedAPKSigningKeys` to its correct position below the `Builds` section.
- Reorder fields within the `Builds` section (move `output` to the top of each build entry).
- Wrap long `flutter build` commands into multiple lines.
- **Fix Build Error:** Add `sed -i '/signingConfig.*release/d' android/app/build.gradle.kts` to the `prebuild` section of each build entry to resolve the `SigningConfig` error.

## Verification Plan

### Automated Tests
- I will run `yamllint metadata/com.dthrawn.ignitebill.yml` to ensure the YAML syntax is valid after my changes.
- Since I don't have the full `fdroid` toolsuite locally, I will rely on the CI's `rewritemeta` and `checkupdates` jobs to confirm the final canonicalization on the next push.

### Manual Verification
- I will manually inspect the `.yml` file to ensure it matches the suggested diff from the CI logs.
