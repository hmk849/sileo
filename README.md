# Sileo（iOS 仿真应用）

SwiftUI · iOS 17+ · 纯本地模拟，不依赖越狱，不安装真实 Deb。

v1.1.0：界面按真 Sileo 2.5.1 还原——英文界面、Featured / News / Packages / Sources / Search 五个 Tab、官方青色主题（#2CB1BE）、真 Sileo 图标、BigBoss / Chariz / Havoc / Procursus 软件源与真实软件包名录。

## 运行
1. `brew install xcodegen`
2. 在本目录执行 `xcodegen generate`，打开 `Sileo.xcodeproj`
3. 选择签名团队，运行

## LiquidGlass 接入
`project.yml` 已声明 SPM 依赖 `https://github.com/rguillen-dev/LiquidGlass`（branch: main）。
所有玻璃效果统一经过 `Sileo/Theme.swift` 的 `GlassSurface`：
将该库提供的玻璃视图/修饰器写入 `#if canImport(LiquidGlass)` 分支即可全局生效。
若库的 product 名不是 `LiquidGlass`，修改 `project.yml` 中 dependencies 的 `product:` 字段。

## 结构
Models（数据/模拟目录）· Store（状态、持久化、安装模拟）· 各页面 View · Theme（颜色/图标/玻璃）
