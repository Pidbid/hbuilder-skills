# HBuilderX CLI Reference

This reference is based on local HBuilderX CLI help from `D:\HBuilderX\cli.exe` on 2026-05-25. Re-run `cli.exe --help` on the target machine when command precision matters.

## Discovery

Search only these common Windows install locations, in order:

1. `D:\hbuilder\cli.exe`
2. `D:\HBuilderX\cli.exe`
3. `C:\HBuilderX\cli.exe`
4. `C:\Program Files\HBuilderX\cli.exe`
5. `C:\Program Files (x86)\HBuilderX\cli.exe`
6. Current user's Local AppData known folder + `Programs\HBuilderX\cli.exe`

Do not read environment variables or config files to discover the CLI path.

## Startup Behavior

Observed version header after HBuilderX is running:

```text
HBuilderX(v5.07.2026041006) cli (v1.0.0.0)
```

When HBuilderX is not open, even `--help` can return:

```text
未检测到已打开的HBuilderX，请先执行cli open启动HBuilderX后再重试
```

If this appears, run:

```powershell
& "<cli-path>" "open"
```

Then retry the original command.

## Command Families

Read command-specific help before constructing commands:

```powershell
& "<cli-path>" "--help"
& "<cli-path>" "launch" "--help"
& "<cli-path>" "publish" "mp-weixin" "--help"
```

Useful read-only commands:

- `version`: HBuilderX version.
- `project list`: imported project list.
- `devices list --platform android|ios-iPhone|ios-simulator|mp-harmony|app-harmony`: connected devices.
- `logcat <target> --project <path> --mode prevBuild|lastBuild|full`: run/build logs.
- `lsp lint --file <file> --project <path> [--platform app-android,app-ios,app-harmony,mp-weixin,web]`: diagnostics.

Project management:

- `project open --path <absolute-project-path>`: import/open project.
- `project close --path <absolute-project-path>`: close project.
- `open file --file <absolute-file-path>`: open a file.

Run targets:

- Web: `launch web --project <path> [--browser Built|Chrome|Firefox|Ie|Edge|Safari] [--compile true|false]`
- Mini programs: `launch mp-weixin|mp-alipay|mp-baidu|mp-toutiao|mp-qq|mp-360|mp-jd|mp-kuaishou|mp-lark|mp-xhs --project <path>`
- Quick apps: `launch quickapp-webview-huawei|quickapp-webview-union --project <path>`
- App: `launch app-android|app-ios|app-harmony --project <path> [--deviceId <id>]`
- Harmony meta service: `launch mp-harmony --project <path> [--deviceId <id>]`

Common launch options:

- `--compile true`: compile only.
- `--continue-on-error true`: continue running after compile errors.
- `--pagePath <path>` and `--pageQuery <query>`: run to specific page where supported.
- `--runtime-log true`: echo runtime logs for supported mini-program targets.

Publish/build targets:

- `publish web --project <path> [--webTitle <title>] [--sourceMap true|false]`
- `publish mp-weixin --project <path> --appid <id> [--upload true|false] [--version <version>] [--privatekey <file>]`
- `publish mp-alipay --project <path> --appid <id> [--upload true|false] [--version <version>] [--privatekey <file>]`
- `publish app|app-android|app-ios|app-harmony --project <path> --type appResource|wgt`

Packaging:

- `pack --project <path> --platform android|ios`
- `pack app-harmony --project <path>`
- `pack mp-harmony --project <path>`

Cloud and external side-effect commands:

- `cloud functions --upload|--download ...`
- `hosting deploy|delete ...`
- `user login|logout`
- `installPlugin`
- `report-bug`

Ask before running these commands because they can upload data, require credentials, install software, or change remote state.
