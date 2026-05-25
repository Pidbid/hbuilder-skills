---
name: hbuilder-cli
description: Assist HBuilderX and uni-app project development with the local HBuilderX CLI. Use when Codex or another AI agent needs to locate HBuilderX cli.exe from common Windows install paths, inspect uni-app or uni-app x projects, run or publish to Web/H5, mini program, App Android/iOS/Harmony targets, collect logs, list devices, manage uni_modules, use HBuilderX LSP diagnostics, or troubleshoot HBuilderX CLI workflow failures.
---

# HBuilder CLI

## Core Rule

Resolve HBuilderX `cli.exe` before every CLI workflow. Search only common install locations. Do not read environment variables, user config files, or project-local CLI config files. If `cli.exe` is not found, stop and report every searched path.

Use `scripts/hbuilder_cli_probe.ps1` for discovery and basic project inspection. The script emits JSON that includes the resolved CLI path, searched paths, version/help status, and uni-app project markers.

Always respond to the user in Chinese. Keep command names, file paths, platform identifiers, and error excerpts unchanged when they are more accurate in their original form.

## Workflow

1. Run the probe from the user's project directory or pass `-ProjectPath`.
2. If `found` is false, stop and report the searched paths.
3. If HBuilderX is not running and CLI output says `未检测到已打开的HBuilderX`, run `cli.exe open` once, then retry the requested help or workflow command.
4. Check the project markers before running project commands. A uni-app project normally has `manifest.json` and `pages.json` at the project root or under `src/`.
5. Choose the CLI command family from the user intent.
6. Run the command with the absolute `cli.exe` path and absolute project path.
7. For run, publish, pack, or troubleshooting tasks, collect the direct CLI output first. If the result failed or is unclear, immediately query `logcat <target> --project <path> --mode lastBuild` or the target-specific log command before proposing a fix.
8. Use CLI output and logs to locate the failing file, platform setting, dependency, or manifest/pages configuration. Edit the project only after the log-backed cause is clear.
9. Re-run the smallest relevant CLI verification after a fix, then summarize the command, exit code, key log lines, changed files, generated artifacts, and any remaining blocker.

## Intent Map

- Inspect CLI/project: run the probe, then read `references/hbuilder-cli.md`.
- Run to platform: use `launch <target> --project <path>`. Targets include `web`, `mp-weixin`, `mp-alipay`, `mp-baidu`, `mp-toutiao`, `mp-qq`, `app-android`, `app-ios`, `app-harmony`, and `mp-harmony`.
- Publish/build artifacts: use `publish <target> --project <path>` after reading target options from CLI help or `references/hbuilder-cli.md`.
- Cloud App package: use `pack` or `pack <target>` only after checking account, certificate, package id, and upload side effects.
- Log-driven repair: after a failed run/build/publish, preserve the CLI output, fetch `logcat <target> --project <path> --mode lastBuild`, identify the actionable error, patch the project, and re-run the smallest relevant CLI command.
- Logs: use `logcat <target> --project <path>` with `--mode prevBuild`, `lastBuild`, or `full`.
- Devices: use `devices list --platform <target-family>` before App or Harmony launch flows.
- LSP diagnostics: use `lsp lint --file <file> --project <path> [--platform ...]`.
- uni_modules: use `uni_modules --list|--download|--upgrade --project <path>`.

## Safety Boundaries

Run read-only commands directly: probe, `version`, help, `project list`, `devices list`, `logcat`, and `lsp lint`.

Ask before commands with external side effects: account login/logout, cloud upload/download, publish upload to mini-program platforms, App cloud packaging, hosting deploy/delete, bug report submission, plugin installation, and any command requiring credentials or private keys.

Never print certificate passwords, private key contents, upload keys, app secrets, or login passwords. If a command needs such a value, ask the user to provide it through their normal secure workflow instead of embedding it into skill files.

## References

- Read `references/hbuilder-cli.md` for common install paths, verified CLI behavior, command families, and examples.
- Read `references/uniapp-workflows.md` for uni-app project inspection, platform prechecks, output locations, and troubleshooting flow.
