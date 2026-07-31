# Task: Fix F-Droid Metadata and Build Errors

- `[x]` Update `metadata/com.dthrawn.ignitebill.yml` with canonical formatting and build fixes
    - `[x]` Add `AutoName: IgniteBill`
    - `[x]` Reformat `Binaries` to multi-line
    - `[x]` Move `AllowedAPKSigningKeys` below `Builds`
    - `[x]` Reorder fields in `Builds` section (move `output` to top)
    - `[x]` Wrap long build commands
    - `[x]` Add `sed` command to `prebuild` to strip `signingConfig`
- `[x]` Verify YAML syntax (Manual inspection performed)
