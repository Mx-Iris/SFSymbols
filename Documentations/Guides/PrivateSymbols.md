# 私有 SF Symbols

> 加载随系统分发、但公共 API 取不到的私有符号。
> 所在模块 / target：`SFSymbols`（trait `PrivateSymbols`），私有方法调用集中在 `SFSymbolsPrivate`。配套提案：[私有 SF Symbols 支持](../Evolutions/0001-private-system-symbols.md)。

面向**调用方**。只讲怎么用、必须遵守什么、有什么坑。

## 快速上手

在依赖方的 `Package.swift` 里打开 trait。要同时用 SwiftUI 的入口，两个 trait 一起开：

```swift
.package(url: "https://github.com/Mx-Iris/SFSymbols", branch: "main", traits: ["SwiftUI", "PrivateSymbols"]),
```

```swift
import SFSymbols

let image = SFSymbols(privateSystemName: .airdrop, pointSize: 20, weight: .bold).nsuiImage
let sameImage = NSUIImage.symbol(privateSystemName: .airdrop, pointSize: 20, weight: .bold)
```

```swift
import SwiftUI
import SFSymbols

struct AirDropLabel: View {
    var body: some View {
        HStack {
            Image(privateSystemName: .airdrop)
            Text("AirDrop")
        }
    }
}
```

## 核心概念

- **[私有符号](../Glossary.md#私有符号)**：放在 `/System/Library/CoreServices/CoreGlyphsPrivate.bundle` 里的符号，macOS 27.2 上有 1902 个，例如 `airdrop`、`persona`。SF Symbols app 不列出它们；`NSImage(systemSymbolName:)`、`UIImage(systemName:)` 返回 nil，`Image(systemName:)` 画出空图。
- **`SFSymbols.PrivateSystemSymbolName`** 与 `SystemSymbolName` 平行，入口一一对应：`SFSymbols(privateSystemName:…)`、`NSUIImage.symbol(privateSystemName:…)`、SwiftUI 的 `Image(privateSystemName:)`。`Image(name:)` 收到私有名字时，也按私有符号处理。
- **名字常量**：`PrivateSystemSymbolName` 上为每个私有名字生成了一个常量（`.airdrop`、`.persona`……），带 `@available`，标明这个名字从哪个系统版本开始出现。清单里没有的名字用 `PrivateSystemSymbolName(rawValue:)`。
- **取图走系统的私有方法**：macOS 上是 `+[NSImage imageWithPrivateSystemSymbolName:accessibilityDescription:]`，iOS、tvOS、watchOS、visionOS、Mac Catalyst 上是 `+[UIImage _systemImageNamed:withConfiguration:]`，SwiftUI 用 `Image(_internalSystemName:)`。它们都先查公共符号集，查不到再查私有符号集，所以公共名字放进 `PrivateSystemSymbolName` 也能取到。
- **不开 trait 就没有这一切**：`SFSymbolsPrivate` 不会被编译进使用方，二进制里没有任何私有方法名，其余 API 的行为与不支持私有符号时完全一样。

## 调用方必须遵守的契约

**取不到图就崩溃，没有返回 nil 的版本。**
名字不存在，或者运行的系统没有对应的私有方法时，`nsImage`、`uiImage`、`nsuiImage` 与 `NSUIImage.symbol(privateSystemName:…)` 都直接 `fatalError`，与公共符号的行为一致。只传在目标系统上确认存在的名字；名字来自用户输入或远端配置时，不要交给本库。
SwiftUI 的 `Image(privateSystemName:)` 在 iOS 14、macOS 11、tvOS 14、watchOS 7 起取不到时只是画出空图，不崩溃；更早的系统上它退回 `Image(uiImage:)`，取不到照样崩溃。

**私有名字不受任何 API 契约保护。**
任何系统版本都可能把它改名或删掉，届时上一条的崩溃就会出现在用户手里。常量上的 `@available` 只说明名字从哪个版本开始有，不保证以后还在。依赖的私有名字要在每个新系统上重新确认。

**上架 App Store 的 App 不要打开这个 trait。**
打开后，二进制里会出现 `imageWithPrivateSystemSymbolName:accessibilityDescription:`、`_systemImageNamed:withConfiguration:` 这类私有方法名，App Store 的审核可能因此拒审。适合在 App Store 之外分发的 App（Developer ID 签名、内部工具）里用。

**名字以 macOS 的私有符号集为准。**
iOS、tvOS、watchOS、visionOS 的私有符号集合可能与 macOS 不同。在这些平台上用之前，先在目标系统上确认名字存在，否则取图崩溃。

## 深入

- **variableValue**：`variableValue(_:)` 与公共符号一样，要 macOS 13、iOS 16、tvOS 16、watchOS 9 起。系统缺少带 variableValue 的私有方法时，退回不带 variableValue 的那个：符号照常显示，只是没有 variableValue 的效果。
- **无障碍描述**：私有方法收到的无障碍描述与公共路径一样是 nil，需要时自己在视图上设置。
- **开关 trait 后 Xcode 报找不到类型**：Xcode 的增量构建可能还用着旧的编译条件，报 `cannot find type 'PrivateSystemSymbolName' in scope`。删掉该项目的 DerivedData 再构建。

## 已知限制

- 没有「取不到返回 nil」的 API。
- iOS 13、tvOS 13、watchOS 6 上是否有 `_systemImageNamed:withConfiguration:` 未经验证，只确认了 macOS 11 的 Mac Catalyst（对应 iOS 14）里已经有它。没有时取图崩溃。
- UIKit 平台只做过编译检查，没有在模拟器或真机上运行过测试。

## 如何验证的

- `Tests/SFSymbolsTests/PrivateSystemSymbolTests.swift`，在 macOS 上用 `swift test --traits PrivateSymbols,SwiftUI` 运行。每个用例先确认公共 API 取不到 `airdrop`、`persona`，再确认本库能取到；另外覆盖配置修饰、variableValue、名字不存在时进程退出，以及 SwiftUI 用 `ImageRenderer` 渲染：私有名字画得出图，不存在的名字画出空图而进程不退出。
- 不开 trait 时，编译产物里没有对私有工厂类的引用；开了才有。在 macOS 上对比两种构建的产物确认过。
- 入口方法来自逆向 macOS 27.0 的 AppKit 与 Mac Catalyst 的 UIKitCore，过程见配套提案。

## 延伸阅读

- 配套提案：[私有 SF Symbols 支持](../Evolutions/0001-private-system-symbols.md)，包括逆向结论与被否决的接入方式。
- 参考实现：PrivateSymbols app 的 `PSSymbolImageFactory`。
