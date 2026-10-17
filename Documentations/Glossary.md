# 术语表

本项目专有名词与约定用法。跨项目通用的术语收在全局术语表中（iCloud Global 镜像的 `Documentations/Glossary.md`），本表不重复登记。

## 收录范围

**收**：项目自造词与内部代号、本项目内反复出现的缩写、通用术语在本项目里的特定含义、容易混淆的近义词对。

**不收**：语言与框架的通用术语（Swift 的 `optional`、SwiftPM 的 trait、AppKit 的 `NSImage`），查官方文档即可。

## 维护约定

提案或文档引入新术语时，同批次登记进本表。文档里首次出现该术语时展开一次并链到这里，之后不必每篇重复解释。

## 术语

### 私有符号

英文 private system symbol。随系统分发、放在 `/System/Library/CoreServices/CoreGlyphsPrivate.bundle` 里的 SF Symbols：SF Symbols app 不列出它们，`NSImage(systemSymbolName:)`、`UIImage(systemName:)`、`Image(systemName:)` 也取不到。本库在 `PrivateSymbols` trait 下用 `SFSymbols.PrivateSystemSymbolName` 表示它们的名字。它指的是符号本身，不是取图时用到的私有 API。

- **主要出现在**：`Sources/SFSymbols/SFSymbols+PrivateSystemSymbols.swift`、`Sources/SFSymbols/SFSymbols+PrivateSystemSymbolName.swift`、[私有 SF Symbols](Guides/PrivateSymbols.md)
- **延伸阅读**：[提案 0001](Evolutions/0001-private-system-symbols.md)、[名字常量的生成](Internal/SymbolNameGeneration.md)
