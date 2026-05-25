# uni-app Workflows

## Project Inspection

Treat a directory as a likely uni-app or uni-app x project when it has one of:

- `manifest.json` and `pages.json` at the project root.
- `src/manifest.json` and `src/pages.json`.

Additional useful markers:

- `package.json`: npm scripts and dependency model.
- `uni_modules/`: plugin modules.
- `vite.config.*`: Vite-based project customization.
- `unpackage/`: generated build/run outputs.

If required markers are missing, stop before running HBuilderX CLI project commands and report what is missing.

## Standard Flow

1. Resolve CLI with `scripts/hbuilder_cli_probe.ps1`.
2. Confirm project markers and absolute project path.
3. Use `project list` to check whether HBuilderX already knows the project.
4. If needed, import with `project open --path <absolute-project-path>`.
5. Run target-specific help before constructing a command.
6. Execute the CLI workflow.
7. Treat the direct CLI output as the first diagnostic artifact.
8. Inspect `logcat <target>` or generated `unpackage/` output when a command fails, succeeds with unclear artifacts, or the user asks the AI to fix the project.
9. Fix the project from log-backed evidence, then re-run the smallest relevant CLI command.

## Prechecks by Target

Web/H5:

- Check `manifest.json` H5 section if the request mentions title, domain, router mode, SSR, or web hosting.
- Use `publish web` for release artifacts and `launch web` for preview or compile-only checks.

Mini programs:

- Check `manifest.json` platform section for the requested mini-program target.
- For upload flows, require appid, version, description, and platform private key file.
- Use `--upload false` or omit upload when the user only wants local build output.
- Ask before upload because it changes the external platform state.

App Android/iOS:

- Check AppID, package/bundle id, certificate requirements, and whether the user wants local resources, WGT, or cloud package.
- Use `publish app-android|app-ios --type appResource` for local package resources.
- Use `publish app-android|app-ios --type wgt` for WGT.
- Use `pack` only after confirming cloud package side effects and credentials.

Harmony:

- Use `launch app-harmony`, `launch mp-harmony`, `pack app-harmony`, `pack mp-harmony`, or `publish app-harmony` according to the requested artifact.
- List devices with `devices list --platform app-harmony` or `devices list --platform mp-harmony` before launch workflows.

## Diagnostics

Use `lsp lint` for source diagnostics when the user asks to inspect a specific file or fix compile errors:

```powershell
& "<cli-path>" "lsp" "lint" "--file" "<file-path>" "--project" "<project-path>" "--platform" "mp-weixin,web"
```

Use `logcat` after failed or unclear run/publish commands:

```powershell
& "<cli-path>" "logcat" "web" "--project" "<project-path>" "--mode" "lastBuild"
```

For runtime visual checks on App targets, `screencap app-android|app-ios|app-harmony` requires an already running project and a `--saveFile` path.

## Log-Driven Repair

Use this flow for real development fixes:

1. Run the user's requested `launch`, `publish`, or `pack` command and keep the full CLI output.
2. If the command fails or the output does not identify a concrete file, run `logcat <target> --project <project-path> --mode lastBuild`.
3. If `lastBuild` is too short, retry with `--mode full` only when more context is needed.
4. Extract the first actionable error, not just the last line. Prefer errors that include a file path, line/column, manifest key, pages route, dependency name, plugin id, appid, certificate, device id, or platform target.
5. Inspect the referenced project files and related config before editing.
6. Make the smallest project fix that matches the log evidence.
7. Re-run the original command, or use a narrower `launch <target> --compile true` / `lsp lint` check when it validates the same failure faster.
8. Report the original error excerpt, the file changed, the verification command, and the remaining log output if the issue is not fully resolved.

Common mappings:

- `manifest.json` or appid errors: inspect platform-specific `manifest.json` sections.
- route/page errors: inspect `pages.json` and the referenced page file.
- dependency/module errors: inspect `package.json`, `node_modules`, and `uni_modules`.
- syntax/type diagnostics: run `lsp lint` on the referenced file.
- device errors: run `devices list` for the target platform before changing project code.
- upload, certificate, login, or remote platform errors: stop and ask for user action unless the fix is purely local config.

## Result Reporting

Always report:

- CLI path used.
- Project path used.
- Command executed.
- Exit code, key CLI output lines, and key `logcat` lines when logs were used.
- Log-backed root cause and changed files for repair tasks.
- Output directory or artifact path when known.
- Any skipped step and the concrete reason.
