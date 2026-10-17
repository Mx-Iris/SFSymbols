# SFSymbols 文档索引

类型化的 SF Symbols 名字与跨 AppKit / UIKit / SwiftUI 的取图入口。**新增或重命名任何文档都必须同步更新这份索引。**

> **项目类型：库（源码分发）**。SPM library product，使用方每次重新编译，无 ABI 约束，但源码兼容性必须评估。

- [术语表](Glossary.md) —— 本项目专有名词，例如「私有符号」。

## 使用指南

- [私有 SF Symbols](Guides/PrivateSymbols.md) —— 打开 `PrivateSymbols` trait 加载系统的私有符号：用法、取不到就崩溃的契约、App Store 审核风险。

## 实现说明

- [名字常量的生成](Internal/SymbolNameGeneration.md) —— 命令插件 `GenerateSymbolNames` 怎么运行、为什么用包内的命令插件、重新生成时会踩的坑。

## 提案

- [Evolutions](Evolutions/README.md) —— 提案索引与状态表。
  - [私有 SF Symbols 支持](Evolutions/0001-private-system-symbols.md)（Implemented）
