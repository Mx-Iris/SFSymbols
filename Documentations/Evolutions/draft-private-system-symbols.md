# Draft - 私有 SF Symbols 支持

- **状态**: Accepted
- **创建日期**: 2026-10-17
- **最后更新**: 2026-10-17
- **实现分支 / PR**: `feature/private-system-symbols`

## 摘要

系统随 OS 分发一批私有符号：SF Symbols.app 不列出它们，公共 API 也取不到。本机 macOS 27.2 的 `CoreGlyphsPrivate.bundle` 里有 1902 个这样的名字，例如 `airdrop`、`persona`。`NSImage(systemSymbolName:)` 和 `UIImage(systemName:)` 对它们一律返回 nil。本提案在新 trait `PrivateSymbols`（默认关闭）下加一套与 `SystemSymbolName` 平行的私有符号支持，包括类型化的名字常量、`SFSymbols` 与 `NSUIImage` 的构造入口，以及 SwiftUI 的 `Image(privateSystemName:)`。不开这个 trait 的使用方，编译出来的东西与现在完全一样。

## 方案

**取图入口**（逆向自 macOS 27.0 cache 的 `AppKit-20261014.i64` 和 Catalyst 版 UIKitCore 的数据库；早于 27.0 的版本，只靠 cache 里有没有对应的方法名字符串来判断）

| 平台 | 入口 | 带 variableValue | 内部做法 |
|---|---|---|---|
| AppKit | `+[NSImage imageWithPrivateSystemSymbolName:accessibilityDescription:]`（macOS 11 起） | `…variableValue:accessibilityDescription:`（macOS 13 起） | 与公共方法调同一个 `_imageWithSystemSymbolName:…allowPrivateLookup:`，只是传 YES。先查公共 catalog，查不到再查私有 catalog |
| UIKit | `+[UIImage _systemImageNamed:withConfiguration:]` | `_systemImageNamed:variableValue:withConfiguration:`（iOS 16 起） | 与公共方法汇合到 `…allowPrivate:`，只是传 YES。私有目录经 `+[SFSCoreGlyphsBundle private]` 加载 |
| SwiftUI | `Image(_internalSystemName:)`（iOS 14 / macOS 11 起，SDK 里下划线开头但公开可调用） | `Image(_internalSystemName:variableValue:)` | — |

两边都没有 entitlement、bundle ID 或内部版本之类的闸门，第三方进程可以用。UIKit 的方法在 macOS 11（Catalyst，对应 iOS 14）的 cache 里已经存在；iOS 13 无从验证，所以调用前一律先检查 `respondsToSelector:`。

**包结构**：新增 trait `PrivateSymbols`。打开它时，`SFSymbols` 才依赖新的 ObjC target `SFSymbolsPrivate`，并定义 `SFSYMBOLS_PRIVATE`；做法与现有的 `SwiftUI` trait、UIFoundation 的 `AppleInternal` trait 一致。`SFSymbolsPrivate` 参照 PrivateSymbols 的 `PSSymbolImageFactory`，写一个工厂类：AppKit、UIKit 各一组方法，系统没有对应方法时返回 nil。所有私有方法名都只出现在这个 target 里。

**API**（全部写在 `#if SFSYMBOLS_PRIVATE` 下，与 `systemName:` 一族一一对应）
- `SFSymbols.PrivateSystemSymbolName`，结构与 `SystemSymbolName` 相同，外加生成的静态常量。
- `SFSymbols(privateSystemName:…)` 6 个构造器，`NSUIImage.symbol(privateSystemName:…)` 6 个重载。
- 同时打开 `SwiftUI` trait 时，新增 `Image(privateSystemName:)`；`Image(name:)` 遇到私有名字也会走 `Image(_internalSystemName:)`。iOS 13、tvOS 13、watchOS 6 上没有这个初始化方法，退回 `Image(uiImage:)`。
- `nsImage` / `uiImage` 的取图逻辑抽成一个私有属性，开头加一个分支：名字是私有的就走私有工厂。配置修饰、variableValue，以及取不到图时 `fatalError`，都与公共符号的行为一致。

**名字常量**：在 `Scripts/` 下新增生成脚本。它读本机私有 bundle 的 `name_availability.plist`，生成 `Sources/SFSymbols/SFSymbols+PrivateSystemSymbolName.swift`，整个文件包在 `#if SFSYMBOLS_PRIVATE` 里。生成文件只放常量（`extension SFSymbols.PrivateSystemSymbolName`），类型本身写在手写的源文件里。排序、驼峰命名、`@available` 的规则都沿用公共清单的生成器（SFSymbolsGenerator 的 struct 模式）。Swift 关键字加反引号，因为私有清单里有一个叫 `switch` 的符号。

**测试**：`swift test --traits PrivateSymbols` 下跑，默认跑法不受影响。
- 先断言公共 API 取不到某个名字，确认它真是私有符号，再断言本库能取到。
- 配置修饰对私有符号生效；variableValue 路径能取到图。
- 用 `ImageRenderer` 把 `Image(privateSystemName:)` 渲染出来，结果非空；`Image(name:)` 给出的结果与它相等。

**没有问、自己定的假设**
- 取不到图时沿用现有契约，直接 `fatalError`，不为私有符号单独改成返回可选值。
- 清单只取自 macOS 的私有 bundle，不为各平台分别生成。iOS 等平台的私有符号集合可能不同，个别名字在那里会取不到。
- 有 71 个名字是未发布产品的 GUID 代号（如 `0828E54B965E418AB42353CA91BFBBEE`），照样生成：规则保持「bundle 里有什么就生成什么」。
- 无障碍描述与公共路径一样传 nil。
- 生成脚本写完先给用户看，再运行。
- 新增使用指南 `Documentations/Guides/PrivateSymbols.md`，写三件事：怎么打开 trait、App Store 审核风险、私有名字不受 API 契约保护，随时可能改名或消失。

## 落地步骤

1. [ ] **包结构与 ObjC 工厂**：`Package.swift` 加 trait `PrivateSymbols`、条件依赖的 target `SFSymbolsPrivate` 和 `SFSYMBOLS_PRIVATE`，写好工厂类。验证：默认构建和 `--traits PrivateSymbols` 构建都通过。
2. [ ] **Swift API、测试与使用指南**：`PrivateSystemSymbolName` 类型（这一步还没有常量，测试用 `init(rawValue:)`），`SFSymbols`、`NSUIImage`、SwiftUI `Image` 的入口，`nsImage` / `uiImage` 的取图分支，测试，`Documentations/Guides/PrivateSymbols.md`。验证：macOS 上四种 trait 组合（都不开、只开 `PrivateSymbols`、只开 `SwiftUI`、都开）的 `swift test` 全部通过；iOS、Mac Catalyst、tvOS、watchOS、visionOS 用 `swift build --triple` 交叉编译通过，不启动模拟器。
3. [ ] **生成脚本**：`Scripts/GeneratePrivateSystemSymbolNames.swift`。写完交给用户审阅，审阅通过前不运行。
4. [ ] **生成名字常量**：运行脚本，提交生成的 `Sources/SFSymbols/SFSymbols+PrivateSystemSymbolName.swift`，测试与指南改用常量。验证同第 2 步。

## 决策日志

| 日期 | 决定 | 理由 |
|------|------|------|
| 2026-10-17 | Created as Draft | 用户原话：「加一下对私有Symbol的支持，具体怎么拿可以逆向AppKit/UIKit，AppKit的创建方法是已知的，参考PrivateSymbols里面的实现」 |
| 2026-10-17 | 用 trait `PrivateSymbols`（默认关闭）加 ObjC target `SFSymbolsPrivate` 接入 | 用户选定。与 `SwiftUI` trait、UIFoundation 的 `AppleInternal` 一致，默认构建里没有私有方法名，现有 5 个依赖方不受影响。否决了两个方案：始终内置，会让所有依赖方都带上私有方法名，有上架风险；单独出一个 product，要把取图分派改成协议钩子，改动面最大 |
| 2026-10-17 | 生成私有名字常量 | 用户选定。否决了只提供 `rawValue` 写法：没有自动补全，不符合本库「类型化名字」的定位 |
| 2026-10-17 | 拆出四个落地步骤；`PrivateSystemSymbolName` 类型写在手写文件里，生成文件只放常量 | 生成脚本要先给用户审阅才能运行。类型与常量分开，前两步不依赖生成结果，可以先实现、先验证 |
| 2026-10-17 | 用户批准，开始实现 | 状态改为 Accepted |
