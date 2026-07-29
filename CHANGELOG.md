# Changelog

## [1.2.3] - 2026-07-29

### Fixed
- Guarded BuildContext usage after async gaps to prevent potential crashes.
- Removed Foojay Java toolchain plugin for better compatibility with restricted build environments (F-Droid).

### Changed
- Transitioned PRO version to a donation-based model for transparency.
- Updated F-Droid metadata and localization (FR/EN).

## [1.2.2] - 2026-07-22

### Added
- Optimized build configuration for F-Droid (ABI split support for armeabi-v7a, arm64-v8a, x86, x86_64).
- Added Fastlane metadata (short/full descriptions) for better store presence.

## [1.2.1] - 2026-07-21

### Fixed
- Fixed APK detection in GitHub Actions and GitLab CI for multi-flavor builds.
- Improved CI/CD reliability for FOSS (F-Droid) releases.

### Added
- Official support for tagged releases (`v*`).
- Automated release creation on GitHub for new tags.

## [1.1.12] - 2026-07-20
- Initial stable release with background timing and PDF generation.
