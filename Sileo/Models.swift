import SwiftUI

struct Repo: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var url: String
    var desc: String
    var symbol: String
    var color: UInt
    var enabled = true
    var isDefault = false
}

struct Pkg: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let version: String
    let author: String
    let summary: String
    let details: String
    let section: String
    let repo: String          // Repo.id
    let symbol: String
    let color: UInt
    let size: Int             // KB
    let depends: [String]
    let changelog: String
    let shots: [String]
}

struct Featured: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let pkg: String
    let c1: UInt
    let c2: UInt
    let symbol: String
}

enum Op: String { case install = "安装", remove = "卸载", update = "更新" }
enum Phase { case confirm, running, done }

struct Job: Identifiable {
    let id = UUID()
    var op: Op
    var pkgs: [Pkg]
    var deps: [Pkg] = []
    var phase: Phase = .confirm
    var progress = 0.0
    var lines: [String] = []
}

struct LogEntry: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    var text: String
}

enum Catalog {
    static let sections = ["调整", "主题", "工具", "实用工具", "开发", "系统"]

    static func pkg(_ id: String) -> Pkg? { all.first { $0.id == id } }

    static let repos: [Repo] = [
        Repo(id: "core", name: "核心软件源", url: "https://repo.sileo.example/core/", desc: "系统运行库与基础组件", symbol: "cube.fill", color: 0x636366, isDefault: true),
        Repo(id: "glimmer", name: "微光源", url: "https://glimmer.example/repo/", desc: "界面调整与视觉增强", symbol: "sparkles", color: 0xFF9F0A),
        Repo(id: "nightowl", name: "夜枭主题源", url: "https://nightowl.example/", desc: "主题、图标与美化", symbol: "moon.stars.fill", color: 0x5E5CE6),
        Repo(id: "geek", name: "极客工坊", url: "https://geekshop.example/apt/", desc: "开发者工具与实用程序", symbol: "hammer.fill", color: 0x30B0C7),
    ]

    static let featured: [Featured] = [
        Featured(id: "f1", title: "夜枭主题引擎 3.0", subtitle: "全新渲染管线，主题切换零延迟", pkg: "com.nightowl.themes", c1: 0x5E5CE6, c2: 0xBF5AF2, symbol: "paintpalette.fill"),
        Featured(id: "f2", title: "Lumen 暗光调节", subtitle: "比系统更暗的夜间显示体验", pkg: "com.lumen.dimmer", c1: 0xFF9F0A, c2: 0xFF375F, symbol: "sun.max.fill"),
        Featured(id: "f3", title: "ViewScope 调试利器", subtitle: "实时查看任意界面的视图层级", pkg: "com.devkit.inspector", c1: 0x0A84FF, c2: 0x30D158, symbol: "viewfinder"),
    ]

    private static func p(_ id: String, _ name: String, _ v: String, _ author: String, _ sum: String, _ det: String,
                          _ sec: String, _ repo: String, _ sym: String, _ col: UInt, _ size: Int,
                          _ deps: [String] = [], _ log: String, _ shots: [String]) -> Pkg {
        Pkg(id: id, name: name, version: v, author: author, summary: sum, details: det, section: sec, repo: repo,
            symbol: sym, color: col, size: size, depends: deps, changelog: log, shots: shots)
    }

    static let all: [Pkg] = [
        p("org.core.libswift", "libswift 运行库", "5.9.0", "Core Team", "Swift 运行时共享库", "为依赖 Swift 的插件提供运行时支持，请勿手动卸载。", "系统", "core", "cube.fill", 0x8E8E93, 9800, [], "• 升级到 Swift 5.9 运行时\n• 修复内存对齐问题", []),
        p("org.core.substrate", "Substitute 注入库", "0.4.2", "Core Team", "轻量级代码注入框架", "为各类调整提供稳定的函数 Hook 能力，启动开销极低。", "系统", "core", "bolt.fill", 0xFFD60A, 1200, ["org.core.libswift"], "• 优化 Hook 稳定性\n• 降低启动耗时 18%", []),
        p("com.lumen.dimmer", "Lumen", "2.4.1", "微光工作室", "比系统更暗的夜间显示", "Lumen 允许亮度降到系统下限以下，并提供色温曲线、定时开关与应用白名单。", "调整", "glimmer", "sun.max.fill", 0xFF9F0A, 2300, ["org.core.substrate"], "• 新增日出日落自动模式\n• 修复锁屏后亮度跳变", ["亮度曲线", "定时设置", "白名单"]),
        p("com.aurora.statusbar", "Aurora 状态栏", "1.8.0", "Aurora Dev", "自定义状态栏样式与图标", "支持显示实时网速、电池温度，自定义时钟格式与图标颜色。", "调整", "glimmer", "waveform.path.ecg", 0x32ADE6, 1750, ["org.core.substrate"], "• 新增网速显示\n• 适配灵动岛机型", ["样式预览", "网速显示"]),
        p("com.zen.haptics", "触感 Pro", "2.0.0", "Zen Labs", "为系统操作添加触觉反馈", "为键盘、开关、锁屏等场景添加可调强度的触觉反馈，并支持自定义波形。", "调整", "glimmer", "iphone.radiowaves.left.and.right", 0xFF453A, 980, ["org.core.substrate"], "• 全新波形编辑器\n• 修复低电量下失效", ["强度设置", "波形编辑"]),
        p("com.nightowl.themes", "夜枭主题引擎", "3.0.2", "NightOwl", "新一代主题渲染引擎", "支持图标、壁纸、锁屏与控制中心的全局主题化，兼容主流主题格式。", "主题", "nightowl", "paintpalette.fill", 0x5E5CE6, 5400, ["org.core.libswift"], "• 全新渲染管线\n• 主题切换速度提升 3 倍", ["主题商店", "图标预览", "锁屏主题"]),
        p("com.glassly.icons", "Glassly 图标包", "1.2.0", "Glassly", "通透玻璃质感图标集", "超过 400 个应用图标，采用多层折射渲染，深浅色自动切换。", "主题", "nightowl", "square.grid.2x2.fill", 0x64D2FF, 21400, ["com.nightowl.themes"], "• 新增 60 个图标\n• 优化深色模式对比度", ["浅色图标", "深色图标"]),
        p("com.xiuyun.files", "岫云文件", "4.1.0", "岫云", "强大的本地文件管理器", "浏览文件系统、预览多种格式、压缩解压、文本编辑，一应俱全。", "工具", "geek", "folder.fill", 0x30B0C7, 7600, [], "• 新增 7z 支持\n• 文本编辑器支持语法高亮", ["文件浏览", "文本编辑"]),
        p("com.snap.shot", "SnapKit 截图", "2.2.0", "SnapLab", "增强的截图与标注工具", "长截图、滚动截图、即时标注与云端分享。", "工具", "geek", "camera.viewfinder", 0xAF52DE, 3100, [], "• 滚动截图精度提升\n• 新增马赛克工具", ["标注", "长截图"]),
        p("com.hack.netmon", "NetPulse", "1.5.3", "NetPulse", "实时网络流量监控", "按应用统计流量，查看连接详情与延迟曲线。", "实用工具", "geek", "network", 0x34C759, 2600, ["org.core.libswift"], "• 新增连接详情\n• 修复统计偏差", ["流量统计", "延迟曲线"]),
        p("com.cloud.sync", "云栈同步", "1.3.4", "CloudStack", "跨设备同步配置与偏好", "备份并同步你的调整设置，换机一键恢复。", "实用工具", "geek", "icloud.fill", 0x0A84FF, 1900, [], "• 同步速度提升\n• 修复冲突合并", ["同步状态"]),
        p("com.devkit.inspector", "ViewScope", "0.9.7", "DevKit", "实时视图层级调试器", "在任意应用中检查视图层级、约束与属性，支持 3D 分层视图。", "开发", "geek", "viewfinder", 0xFF375F, 4300, ["org.core.substrate", "org.core.libswift"], "• 新增 3D 分层视图\n• 修复约束显示错位", ["3D 视图", "属性面板"]),
        p("com.devkit.logcat", "Logcat 日志", "1.1.0", "DevKit", "系统日志实时查看器", "过滤、搜索并导出系统日志，支持按进程着色。", "开发", "geek", "terminal.fill", 0x2C2C2E, 1500, ["org.core.libswift"], "• 新增进程着色\n• 支持导出为文本", ["日志流"]),
    ]
}
