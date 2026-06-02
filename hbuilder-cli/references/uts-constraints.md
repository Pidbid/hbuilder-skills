# UTS 关键约束（基于实战总结）

> 适用范围：uni-app x 项目，目标平台 APP-ANDROID，Vue 3 + UTS。
> 每次写完代码后必须根据以下规则自检有没有犯错。

## 类型系统

| 规则 | 说明 |
|------|------|
| `type` 代替 `interface` | 对象字面量赋值给类型时必须用 `type` 定义；`interface` 接收对象字面量会触发 UTS110111163 错误 |
| 禁止内联对象字面量类型 | `function f(x: {a:number})` → 提取为命名 `type` |
| `any` 不可方括号/点号访问 | `row["key"]` 和 `row.key` 均不支持，必须用 `Map<string,any>` + `.get("key")` |
| `any = null` 需 `any \| null` | 可空 any 必须显式声明 |
| `String(x)` 仅接受 CharArray/StringBuffer/StringBuilder | 转换数字用 `'' + n` |
| `Number()` 是抽象类 | 解析数字用 `parseFloat()` 或 `parseInt()` |
| `parseFloat()`/`parseInt()` 仅接受 `String` | 不接受其他类型 |
| `JSON.parse()` 仅接受 `String` | 从 `uni.getStorageSync` 取值需 `JSON.parse(raw as string)` |
| 数组索引返回可空 | `arr[0]` 返回 `T?`，需 `as string` 等断言 |
| regex 捕获组 `match[1]` 返回 `String?` | 需 `as string` 断言 |
| `charAt()` 返回 `Char` | 不能与 `String` 字面量 `===` 比较；用 `substring(i,i+1)` |
| `Infinity` 不存在 | 用大数值(999999999)替代 |
| `ref<any[]>` / `computed<any[]>` 禁止 | 必须使用具体类型如 `ref<DailyCount[]>([])` |
| 跨文件类型必须 `export` | 否则调用方无法命名该类型 |

## 对象操作

| 规则 | 说明 |
|------|------|
| 禁止 `obj["key"] = val` 方括号赋值 | 通过 `JSON.parse(jsonStr)` 构造新对象或 `Map.set()` |
| 禁止 `Object.keys()` | 改用内部自维护的 `cols: string[]` 数组 |
| `.map(funcRef)` 函数引用不支持 | 必须包装为箭头：`rows.map((r: any): T => mapRow(r))` |
| 模板字面量 `${expr}` 不支持 | 改为 `'str' + expr + 'str'` 字符串拼接 |
| 对象展开 `{...obj}` 有风险 | 数组展开 `[...a, ...b]` **禁止使用**，改用 `.concat()` |
| `JSON.parse()` 返回 `any` | 直接访问属性编译失败，必须 `JSON.parse(str) as NamedType` 转换 |

## API 差异

| 规则 | 说明 |
|------|------|
| 无 `plus.xxx` | 用 `uni.xxx` 或标准 `setTimeout` |
| `uni.getStorageSync` 返回 `any` | 判空后需 `as string` 转换再操作 |
| 数据库返回 `Map<string,any>[]` | 通过 `row.get("column_name")` 取值 |
| `uniCloud.callFunction` 不兼容 UTS | 改用 `uni.request` HTTP 直连 |
| `uni.request` success/fail 回调参数不要标 `any` | 移除类型标注让编译器推断为 `UniRequestCallbackResult` |
| `uni.vibrateShort` 必须传 `type` 参数 | `type: 'light' \| 'medium' \| 'heavy'`；`vibrateLong` 不需要 |

## UVUE 组件规范

| 规则 | 说明 |
|------|------|
| Props 中导入复杂 type 需内联定义 | 到组件内重新定义 |
| 模板访问嵌套属性需 computed 中转 | 不可直接 `{{ props.action.name }}` |
| CSS 仅支持 class 选择器 | `display:flex` 必须显式 `flex-direction` |
| App 端滚动需 `#ifdef APP` + `<scroll-view>` | — |
| 必须用 Composition API（`<script setup>`） | Options API 的 `this.xxx` 返回 any，模板 any 泄漏 |
| 子组件对象 prop + computed 字段访问 → 运行时崩溃 | 子组件只接收基础类型(string/number/boolean) prop |

## 命名约定

- **文件**：PascalCase.uts（类型定义），camelCase.uts（工具/服务）
- **DAO**：`get*By*(...)`、`insert*`、`update*`、`count*`、`cleanOldData()`
- **组件**：PascalCase.uvue，props 用 `withDefaults(defineProps<{...}>(), {})`
- **Model type**：`type Xxx = { field: Type; ... }`
- **数据库列名**：snake_case；返回 Map 键名使用 snake_case 原始列名

## 错误处理

- DAO 函数吞异常为静默错误（返回默认值或空数组）
- DatabaseManager 异常通过 `console.error` 输出
- 关键初始化在 `App.uvue` 的 `onLaunch` 中 try-catch

## UI 组件通信

- Props down / Emits up：`defineEmits<{(e:'eventName', payload:Type):void}>()`
- 全局状态通过 `stores/appStore.uts` 的 `ref` 暴露，页面 `import { useAppStore }` 调用 `refreshHomeData()`

## 运算符与控制流

| 规则 | 说明 |
|------|------|
| `\|\|` 运算符严格要求 Boolean 操作数 | `Map.get()` 返回 `V \| null`、`arr[i]` 返回 `T \| null`、可选字段 `T \| null` 都不能用 `\|\|` 短路，必须显式 `if (x != null)` 或三元 |
| 函数不提升（no hoisting） | `<script setup lang="uts">` 中所有被调用函数必须定义在调用者之前 |
| 对象类型必须用 `type` | 禁止 `interface`（UTS110111163），包括函数参数、返回类型、传参位置 |

## Android 平台特定

| 规则 | 说明 |
|------|------|
| Java Intent 必须导入 | `import Intent from 'android.content.Intent'`，禁止混搭全限定名 |
| `X_SERVICE` 常量在 `Context` 上 | 不在 `Service`/`WindowManager`/`Activity` 上，需 `import Context from 'android.content.Context'` |
| Android 视图构造函数参数必须是 `Context` | 禁止 `any`，`UTSAndroid.getAppContext()` 直接返回 `Context` |
| 模块级 `let`/类 `private` 可变属性访问需 `!!` | UTS 编译器不做 smart cast，即使 `if (x != null)` 块内也需 `x!!.method()` |
| UTS 严格数值类型 | 无隐式 `Number→Int` / `Double→Float` 转换，需 `.toInt()`/`.toFloat()`/`.toLong()` |
| `number` 字段传给 Android Int 形参需 `.toInt()` | `setMax(Int)`、`setProgress(Int)` 等 API 必须显式转换 |
| `extends Java/Kotlin 抽象类` override 签名必须精确匹配 | 父类 `Int` ≠ 子类 `number`，`SQLiteDatabase!` ≠ `SQLiteDatabase \| null` |
| `SQLiteStatement` 比 `ContentValues + execSQL` 更稳 | `ContentValues.put(key, null)` 编译失败，用 `bindNull` 替代 |
| Java 监听器接口不需要 `new` | `X.OnXxxListener({...})` 工厂调用可用；构造函数+监听器参数必须传纯函数 |

## HBuilderX 构建

| 命令 | 说明 |
|------|------|
| HBuilderX `运行 → 运行到手机或模拟器` | 运行到 Android |
| `hbuilderx_cli_path` | `D:\Program Files (x86)\HBuilderX\cli.exe` |
| `node_exec_path` | `D:\Program Files (x86)\HBuilderX\plugins\node\node.exe` |

**无 lint / 无测试 / 无 package.json**。语法检查通过 HBuilderX 内置编译器完成。

## HBuilderX 5.x uts 插件合并机制

**【最高优先级】Android Service/Receiver/Provider 等需要 manifest 注册的组件，必须放在 `utssdk/app-android/AndroidManifest.xml` 才会被合并。**

- `config.json` 的 `permissions`/`services`/`receivers` 数组 → **完全忽略**
- `config.json` 的 `id`/`name`/`version`/`dependencies` → 生效
- `manifest.json`（应用级）的 `android.permissions`/`android.minSdkVersion` → 生效

**最佳实践**：
- 公共权限放在 `manifest.json` 的 `app.distribute.android.permissions`
- 插件专有权限/组件放在 `uni_modules/<plugin>/utssdk/app-android/AndroidManifest.xml`
- `config.json` 只放 `id`/`name`/`version`/`dependencies`

## Canvas API

```uts
// ❌ uni.createCanvasContext — 不存在（uni-app x 无此老版 API）
// ❌ ctx.setFillStyle / ctx.setFontSize / ctx.setStrokeStyle — 非标准方法

// ✅ 正确：uni.createCanvasContextAsync + W3C 标准 Canvas 2D API
onReady(() => {
  uni.createCanvasContextAsync({
    id: 'canvas',
    component: getCurrentInstance().proxy,
    success: (context: CanvasContext) => {
      const ctx = context.getContext('2d')!
      const canvas = ctx.canvas
      const dpr = uni.getDeviceInfo().devicePixelRatio ?? 1
      canvas.width = canvas.offsetWidth * dpr
      canvas.height = canvas.offsetHeight * dpr
      ctx.scale(dpr, dpr)
      // W3C 标准 API：属性赋值，不是 setXxx()
      ctx.fillStyle = '#4CAF50'
      ctx.font = '14px sans-serif'
      ctx.textAlign = 'center'
      ctx.fillRect(x, y, w, h)
      ctx.fillText(text, x, y)
    }
  })
})
```

## 返回类型与对象字面量

当函数签名声明了具体类型，`return { ... }` 推断为 `UTSJSONObject` 而非目标类型。**必须先赋值给带类型注解的局部 const，再返回/传参**：

```uts
function getInfo(): AppForegroundInfo | null {
  if (this.pkg.isEmpty()) return null
  const info: AppForegroundInfo = {
    packageName: this.pkg, startTime: this.startTime, continuousMs: this.elapsed
  }
  return info
}
```
