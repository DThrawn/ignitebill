# Task: Fix F-Droid Metadata and Build Errors

- `[ ]` Update `metadata/com.dthrawn.ignitebill.yml` with canonical formatting and build fixes
    - `[ ]` Add `AutoName: IgniteBill`
    - `[ ]` Reformat `Binaries` to multi-line
    - `[ ]` Move `AllowedAPKSigningKeys` below `Builds`
    - `[ ]` Reorder fields in `Builds` section (move `output` to top)
    - `[ ]` Wrap long build commands
    - `[ ]` Add `sed` command to `prebuild` to strip `signingConfig`
- `[ ]` Verify YAML syntax
