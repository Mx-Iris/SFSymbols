# Evolution 提案索引

- **项目类型**: 库（源码分发）

SPM library product，使用方以源码依赖并重新编译，未开启 library evolution。提案的「ABI 兼容性」填「不适用 —— 本库以 SPM 源码分发，使用方每次重新编译」即可，「源码兼容性」必填。

已知下游：SymbolViewer、XMLViewer、LocalizationStudio（开了 `SwiftUI` trait）、ReverseEngineeringToolbox、XCOrganizer。

提案格式与流程见全局 `CLAUDE.md` 的「Evolution 提案制」一节。

## 提案

| # | 标题 | 状态 | 摘要 |
|---|------|------|------|
| draft | [私有 SF Symbols 支持](draft-private-system-symbols.md) | Accepted | 在新 trait `PrivateSymbols`（默认关闭）下加入私有符号：生成的 `PrivateSystemSymbolName` 常量、`SFSymbols` / `NSUIImage` / SwiftUI `Image` 的入口，经 ObjC target `SFSymbolsPrivate` 调用 AppKit / UIKit 的私有工厂方法。 |
