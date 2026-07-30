# Implementation Plan - Fix GitLab CI/CD for IgniteBill

This plan addresses the identified failures in the GitLab CI/CD pipeline for the `ignitebill` project on the `f-droid-clean-sync` branch.

## Proposed Changes

### [GitLab CI Configuration]

#### [MODIFY] [.gitlab-ci.yml](https://gitlab.com/DThrawn/ignitebill/-/blob/f-droid-clean-sync/.gitlab-ci.yml)
- Change the Java version from 21 to 17 in the `fdroid build` job. The app's Gradle build requires Java 17 for its toolchain, but the CI environment was forcing Java 21.

### [F-Droid Metadata]

#### [MODIFY] [metadata/com.dthrawn.ignitebill.yml](https://gitlab.com/DThrawn/ignitebill/-/blob/f-droid-clean-sync/metadata/com.dthrawn.ignitebill.yml)
- Apply canonical formatting to satisfy the `fdroid rewritemeta` check.
- Fix whitespace in the `Binaries:` key.
- Remove redundant empty lines.
- Ensure categories and fields are in the order expected by F-Droid tools.

## Verification Plan

### Automated Tests
- I will use the GitLab API to trigger a new pipeline on the `f-droid-clean-sync` branch.
- I will monitor the pipeline status and check that `fdroid build` and `fdroid rewritemeta` jobs pass.

### Manual Verification
- Verify that the resulting APK is correctly built and available as a job artifact.
