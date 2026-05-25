# HBuilder Skills

本仓库提供面向 AI Agent 的 HBuilderX / uni-app 开发辅助 skill。

当前 skill：

- `hbuilder-cli`：通过本机 HBuilderX `cli.exe` 辅助 uni-app / uni-app x 项目检查、运行、发行、日志收集、设备列表、LSP 诊断和常见问题排查。

## Agent 快速识别

```yaml
skill_name: hbuilder-cli
skill_dir: hbuilder-cli
skill_entry: hbuilder-cli/SKILL.md
primary_script: hbuilder-cli/scripts/hbuilder_cli_probe.ps1
language: zh-CN
install_rule: copy skill_dir into the target AI skills directory
```

## 设计目标

- 使用标准 skill 目录格式，兼容支持 `SKILL.md` 的 AI Agent。
- 让 AI 直接查看仓库后，可以识别 skill 目录并自动安装。
- 不要求用户配置 HBuilderX 路径。
- HBuilderX CLI 只从常见安装位置扫描；找不到就明确报错。
- 使用该 skill 时，最终回复必须使用中文。

## 目录结构

```text
hbuilder-skills/
├── hbuilder-cli/
│   ├── SKILL.md
│   ├── agents/
│   │   └── openai.yaml
│   ├── references/
│   │   ├── hbuilder-cli.md
│   │   └── uniapp-workflows.md
│   └── scripts/
│       └── hbuilder_cli_probe.ps1
├── LICENSE
└── README.md
```

## AI 自动安装协议

当 AI Agent 被要求安装本仓库的 skill 时，按以下规则执行：

1. 先识别目标 AI Agent 的 skills、plugins、extensions 或 tools 目录。
2. 将仓库中的 `hbuilder-cli/` 整个目录复制到该目标目录下。
3. 保持目录名为 `hbuilder-cli`。
4. 保持 `SKILL.md` 位于 `hbuilder-cli/SKILL.md`。
5. 不要把仓库根目录整体作为 skill 安装。
6. 不要改写 HBuilderX CLI 安装路径规则。
7. 安装后运行目标 AI 支持的 skill 校验；如果没有校验工具，至少检查 `SKILL.md` frontmatter 中的 `name` 和 `description`。

安装后的通用形态应为：

```text
<target-skills-root>/
└── hbuilder-cli/
    ├── SKILL.md
    ├── agents/
    ├── references/
    └── scripts/
```

目标目录示例：

- Codex：`%USERPROFILE%\.codex\skills`
- 其他支持 `SKILL.md` 的 AI Agent：使用该 Agent 文档定义的 skills、plugins、extensions 或 tools 目录。

## 通用安装命令

在仓库根目录执行 PowerShell：

```powershell
$repo = (Get-Location).Path
$source = Join-Path $repo "hbuilder-cli"
$targetSkillsRoot = "<目标 AI 的 skills/plugins/extensions/tools 目录>"
$target = Join-Path $targetSkillsRoot "hbuilder-cli"
New-Item -ItemType Directory -Force -Path $targetSkillsRoot
Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
```

将 `<目标 AI 的 skills/plugins/extensions/tools 目录>` 替换为实际目录。

Codex 示例：

```powershell
$repo = (Get-Location).Path
$source = Join-Path $repo "hbuilder-cli"
$targetSkillsRoot = Join-Path $HOME ".codex\skills"
$target = Join-Path $targetSkillsRoot "hbuilder-cli"
New-Item -ItemType Directory -Force -Path $targetSkillsRoot
Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
```

安装后验证：

```powershell
Test-Path -LiteralPath (Join-Path $target "SKILL.md")
```

如果目标 AI 提供标准校验工具，优先使用其校验工具。Codex skill-creator 校验示例：

```powershell
$env:PYTHONUTF8 = "1"
python "C:\Users\<用户名>\.codex\skills\.system\skill-creator\scripts\quick_validate.py" "$HOME\.codex\skills\hbuilder-cli"
```

## 给 AI Agent 的安装摘要

```text
Install this repository by copying only ./hbuilder-cli into the target agent's skill/plugin/extension root.
The installed entry file must be ./hbuilder-cli/SKILL.md.
Do not install the repository root as the skill.
Do not change the skill name, directory name, or HBuilderX CLI discovery rules.
After installation, validate SKILL.md frontmatter or run the target agent's skill validator.
```

<!--
Machine-readable install hints:
skill_name=hbuilder-cli
source_dir=./hbuilder-cli
entry=./hbuilder-cli/SKILL.md
install_shape=<target-skills-root>/hbuilder-cli/SKILL.md
language=zh-CN
-->

## 基本使用方法

安装后，在支持 skills 的 AI 中直接提出与 HBuilderX / uni-app CLI 相关的任务，例如：

```text
使用 $hbuilder-cli 检查当前 uni-app 项目，并告诉我能否运行到微信小程序。
```

```text
使用 $hbuilder-cli 运行这个项目到 web，失败时读取 HBuilderX 日志并定位原因。
```

```text
使用 $hbuilder-cli 运行到微信小程序；如果失败，先查看 CLI 输出和 HBuilderX logcat 日志，再根据日志修复项目并重新验证。
```

```text
使用 $hbuilder-cli 对 src/pages/index/index.vue 做 LSP 诊断。
```

```text
使用 $hbuilder-cli 查看 Android 设备列表，并判断是否能运行 App。
```

## HBuilderX CLI 查找规则

skill 不读取环境变量，不读取用户配置，也不读取项目本地 CLI 配置文件。

它只扫描以下常见位置：

```text
D:\hbuilder\cli.exe
D:\HBuilderX\cli.exe
C:\HBuilderX\cli.exe
C:\Program Files\HBuilderX\cli.exe
C:\Program Files (x86)\HBuilderX\cli.exe
%LOCALAPPDATA%\Programs\HBuilderX\cli.exe
```

如果这些位置都找不到 `cli.exe`，AI 必须停止 HBuilderX CLI 操作，并报告已搜索路径。

## 本地探测

可以直接运行探测脚本确认当前机器状态：

```powershell
$repo = (Get-Location).Path
$probe = Join-Path $repo "hbuilder-cli\scripts\hbuilder_cli_probe.ps1"
powershell -ExecutionPolicy Bypass -File $probe -ProjectPath "D:\path\to\uniapp-project"
```

脚本会输出 JSON，包括：

- 是否找到 `cli.exe`
- 使用的 CLI 路径
- 已搜索路径
- HBuilderX 版本
- 当前目录是否像 uni-app 项目

## 适用范围

适合：

- uni-app / uni-app x 项目检查
- HBuilderX CLI 运行、发行、打包流程辅助
- 基于 CLI 输出和 HBuilderX `logcat` 日志定位问题、修改项目并重新验证
- Web/H5、小程序、App Android/iOS/Harmony 目标排查
- HBuilderX 日志、设备、LSP 诊断、uni_modules 管理

不适合：

- 自动安装 HBuilderX 本体
- 代替微信、支付宝、iOS、Android、Harmony 等外部平台的账号和证书配置
- 在没有用户确认的情况下执行上传、云打包、登录、发布等外部副作用操作
