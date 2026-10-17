# 名字常量的生成：实现说明

> 配套提案见 [私有 SF Symbols 支持](../Evolutions/0001-private-system-symbols.md)。
> 本文记录生成名字常量的命令插件 `GenerateSymbolNames`：怎么运行、为什么这样做、有哪些坑。面向维护者。

## 背景与目标

`SystemSymbolName` 与 `PrivateSystemSymbolName` 上的静态常量都是生成的，一个名字一个常量，带 `@available`。公共名字来自 SF Symbols app 的名字清单，私有名字来自运行插件的那台 Mac 的 `CoreGlyphsPrivate.bundle`。新的 SF Symbols 或新系统发布后，由维护者重新运行插件、检查差异、提交。

## 怎么运行

- **Xcode**：打开本包的 `Package.swift`，在导航栏里对 SFSymbols 包运行命令插件 `GenerateSymbolNames`（右键菜单）。第一次运行时 Xcode 会请求写入包目录的权限。
- **命令行**（在包根目录）：`swift package --allow-writing-to-package-directory generate-symbol-names`
- 参数 `--beta`：公共名字改从 `/Applications/SF Symbols beta.app` 读，默认读 `/Applications/SF Symbols.app`。

插件改写 `Sources/SFSymbols/` 下的两个文件，并为每个文件打印一行：名字总数、来源，以及与改写前相比新增、删除了多少个名字。

| 文件 | 来源 | 包在 |
|---|---|---|
| `SFSymbols+SystemSymbolName.swift` | SF Symbols app 的 `Contents/Resources/Metadata/name_availability.plist` | — |
| `SFSymbols+PrivateSystemSymbolName.swift` | `/System/Library/CoreServices/CoreGlyphsPrivate.bundle/Contents/Resources/name_availability.plist` | `#if SFSYMBOLS_PRIVATE` |

## 关键设计决策

**生成器写在本包的命令插件里，不改造 SFSymbolsGenerator。** 原先的公共常量由 SFSymbolsGenerator 生成。它的 fork 停在 v1.1.0，输出的类型名是旧的 `SFSymbol`，每次生成后都要手改成 `SFSymbols`；作为插件的依赖，还会给 SFSymbols 加一个包依赖（连带 swift-argument-parser）。本包的插件不进任何 product，使用方既看不到它，也不用解析它。

**命令插件，不是构建插件。** 构建插件会在每个使用方的每次构建里读本机的 SF Symbols app 和系统私有 bundle：结果随机器而变，没装 SF Symbols app 的机器（比如 CI）直接构建失败。所以生成结果提交进仓库，由维护者按需更新。

**生成文件只放常量。** `SystemSymbolName` 的类型定义在 `SFSymbols+SymbolName.swift`，`PrivateSystemSymbolName` 的在 `SFSymbols+PrivateSystemSymbols.swift`。两份生成文件因此共用一个模板，也不会在重新生成时冲掉手写的内容。

**命名规则沿用 SFSymbolsGenerator，只有一处不同。** 先按发布年份、再按名字排序；名字按 `.` 拆开，第一段保持原样，其余各段首字母大写后拼起来；以数字开头的前面加 `_`；`@available` 列出该年份对应的各平台版本。不同之处：所有 Swift 关键字都加反引号，而 SFSymbolsGenerator 只处理 `return`、`case`、`repeat`。私有清单里有一个叫 `switch` 的符号，必须这样处理。

**忽略 `--target`，其他不认识的参数一律报错。** Xcode 运行插件时，会把对话框里选中的 target 用 `--target` 传进来；插件只生成 SFSymbols 这一个 target，选了哪些不影响结果。其他参数照样报错，免得把 `--beta` 拼错后悄悄读了正式版的 app。

**两份清单都读完、校验通过才动文件，任何一项出错就报错退出，两份文件都不动。** 校验三项：发布年份查不到平台版本、名字转不成合法的 Swift 标识符、两个名字转成了同一个标识符。这样系统新增的怪名字会立刻暴露，而不是生成出编译不过的文件，也不会只更新了一半。

## 模块结构

```
Plugins/GenerateSymbolNames/
├── GenerateSymbolNames.swift   # 插件入口：解析参数，定位两个输入与两个输出，打印增删统计
└── SymbolNameList.swift        # 读 name_availability.plist、校验、按命名规则生成 Swift 源码
```

## 已知的坑

- **删除名字就是破坏源码兼容性。** 插件打印的「删除」不是 0 时，调用方引用的常量可能消失。提交前先查清原因：SF Symbols 改名、换了旧版本的 app，还是在旧系统上运行了插件。
- **私有清单随运行插件的系统而变。** 在比上次更旧的 macOS 上运行，会删掉新系统才有的私有名字。生成文件的第二行记着来源的版本，运行前先对一下。
- **没装 SF Symbols app 时插件报错退出**，私有清单也不会更新。只想更新私有清单也得先装上它。

## 验证

- 第一次运行（2026-10-18，SF Symbols 27.0，macOS 27.2，带着 Xcode 会传的 `--target` 参数）：公共清单 9524 个名字，比 SFSymbolsGenerator 生成的旧文件多 340 个、没有删除，旧文件里 9184 个常量的每一行都没变，说明排序、命名、`@available` 与 SFSymbolsGenerator 一致；私有清单 1902 个。
- 生成结果靠编译与测试兜底：名字转错会编译失败，私有符号的测试直接引用生成的常量 `.airdrop`。
- 插件代码不能被测试 target 导入，所以没有自动化测试；改动插件后按上面的方式运行一次，看打印的增删统计与 `git diff`。

## 延伸阅读

- 配套提案：[私有 SF Symbols 支持](../Evolutions/0001-private-system-symbols.md)
- 使用指南：[私有 SF Symbols](../Guides/PrivateSymbols.md)
