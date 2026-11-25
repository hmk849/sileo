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

enum Op: String { case install = "Install", remove = "Remove", update = "Update" }
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
    static let sections = ["Tweaks", "Themes", "Utilities", "Applications", "Games", "Developer"]

    static func pkg(_ id: String) -> Pkg? { all.first { $0.id == id } }

    static let repos: [Repo] = [
        Repo(id: "bigboss", name: "BigBoss", url: "https://apt.thebigboss.org/repofiles/cydia/", desc: "The largest Cydia repository", symbol: "cube.fill", color: 0x0A84FF, isDefault: true),
        Repo(id: "chariz", name: "Chariz", url: "https://repo.chariz.com/", desc: "Premium tweaks and themes", symbol: "sparkles", color: 0xBF5AF2, isDefault: true),
        Repo(id: "havoc", name: "Havoc", url: "https://havoc.app/", desc: "Modern tweak repository", symbol: "bolt.fill", color: 0xFF375F, isDefault: true),
        Repo(id: "procursus", name: "Procursus", url: "https://apt.procurs.us/", desc: "Core libraries and tools", symbol: "hammer.fill", color: 0x30B0C7, isDefault: true),
    ]

    static let featured: [Featured] = [
        Featured(id: "f1", title: "SnowBoard 1.5", subtitle: "Icon theming, rebuilt for the modern era", pkg: "com.sparkdev.snowboard", c1: 0x2CB1BE, c2: 0x0A84FF, symbol: "paintpalette.fill"),
        Featured(id: "f2", title: "Filza File Manager", subtitle: "The most powerful file manager on iOS", pkg: "com.tigisoftware.filza", c1: 0xFF9F0A, c2: 0xFF375F, symbol: "folder.fill"),
        Featured(id: "f3", title: "NewTerm 3", subtitle: "A full terminal in your pocket", pkg: "ws.hbang.newterm3", c1: 0x0A84FF, c2: 0x30D158, symbol: "terminal.fill"),
    ]

    private static func p(_ id: String, _ name: String, _ v: String, _ author: String, _ sum: String, _ det: String,
                          _ sec: String, _ repo: String, _ sym: String, _ col: UInt, _ size: Int,
                          _ deps: [String] = [], _ log: String, _ shots: [String]) -> Pkg {
        Pkg(id: id, name: name, version: v, author: author, summary: sum, details: det, section: sec, repo: repo,
            symbol: sym, color: col, size: size, depends: deps, changelog: log, shots: shots)
    }

    static let all: [Pkg] = [
        p("org.coolstar.libhooker", "libhooker", "1.6.10", "CoolStar", "Hooking library for tweaks", "libhooker provides stable function hooking for tweaks built against modern toolchains. Required by many packages — do not remove it manually.", "Tweaks", "procursus", "bolt.fill", 0xFFD60A, 1240, [], "• Improved hook stability\n• Lower launch overhead", []),
        p("com.ex.substitute", "Substitute", "2.3.1", "comex", "Code injection framework", "Substitute is the lightweight code injection framework that powers most tweaks. It replaces functions at runtime with minimal overhead.", "Tweaks", "procursus", "bolt.fill", 0xFF453A, 1180, ["org.coolstar.libhooker"], "• Fixed a rare crash on launch\n• Reduced memory footprint", []),
        p("ws.hbang.common", "PreferenceLoader", "3.0.0", "Dustin Howett", "Loads tweak preferences", "PreferenceLoader lets tweaks add their own panels to the Settings app. Almost every tweak depends on it.", "Tweaks", "bigboss", "gearshape.fill", 0x8E8E93, 420, [], "• Fixed preference loading on iOS 16+\n• Faster Settings launch", []),
        p("com.rpetrich.applist", "AppList", "1.5.17", "Ryan Petrich", "Application list library", "AppList lets tweaks enumerate installed applications and their icons. A dependency of many popular tweaks.", "Tweaks", "bigboss", "square.grid.2x2.fill", 0x0A84FF, 380, [], "• Added support for new app types\n• Bug fixes", []),
        p("com.rpetrich.rocketbootstrap", "RocketBootstrap", "1.0.10", "Ryan Petrich", "Inter-process communication", "RocketBootstrap provides a secure IPC mechanism that lets tweaks talk to each other and to system services.", "Tweaks", "bigboss", "network", 0x34C759, 260, [], "• Improved IPC reliability\n• Security fixes", []),
        p("com.chariz.cephei", "Cephei", "1.17", "Chariz", "Developer framework for tweaks", "Cephei is a framework that makes it easy for developers to build beautiful tweak preference bundles.", "Developer", "chariz", "hammer.fill", 0xBF5AF2, 540, [], "• New preference cell types\n• Dark mode fixes", []),
        p("com.sparkdev.snowboard", "SnowBoard", "1.5.21", "SparkDev", "Icon theming engine", "SnowBoard is the modern theming engine. Apply icon themes, fonts and more — with live previews and per-app overrides.", "Themes", "chariz", "paintpalette.fill", 0x2CB1BE, 2100, ["org.coolstar.libhooker"], "• Faster theme switching\n• Fixed icon cache issues", ["Theme Store", "Icon Preview", "Per-App Themes"]),
        p("com.mtac.lynx2", "Lynx 2", "2.6.0", "MTAC", "System-wide customization", "Lynx 2 lets you customize nearly every part of iOS — lock screen, home screen, status bar, Control Center and more, all in one place.", "Tweaks", "chariz", "slider.horizontal.3", 0x5E5CE6, 3400, ["org.coolstar.libhooker", "com.chariz.cephei"], "• Added new lock screen options\n• Fixed Control Center glitches", ["Lock Screen", "Home Screen", "Status Bar"]),
        p("com.noisyflake.velvet2", "Velvet 2", "2.1.0", "NoisyFlake", "Notification customization", "Velvet 2 redesigns your notifications with custom banners, colors and layouts — make them yours.", "Tweaks", "havoc", "bell.badge.fill", 0xFF375F, 1500, ["org.coolstar.libhooker"], "• Added banner color presets\n• Fixed notification grouping", ["Banner Styles", "Colors"]),
        p("com.sugiuta.atria", "Atria", "1.5.1", "Sugiuta", "Home screen layout editor", "Atria gives you a grid editor for your home screen — move, resize and hide icons freely.", "Tweaks", "havoc", "rectangle.grid.3x3.fill", 0x64D2FF, 980, ["org.coolstar.libhooker"], "• Improved grid snapping\n• Fixed icon overlap", ["Grid Editor"]),
        p("com.muirey03.copylog", "CopyLog", "1.4.3", "Muirey03", "Clipboard history manager", "CopyLog keeps a history of everything you copy, so you can paste anything you copied earlier.", "Utilities", "havoc", "doc.on.clipboard.fill", 0x30D158, 720, [], "• Added search in history\n• Fixed clipboard sync", ["History", "Search"]),
        p("com.tigisoftware.filza", "Filza File Manager", "4.0.0", "TIGI Software", "The most powerful file manager", "Browse the entire filesystem, preview files, compress and decompress, edit text and manage apps — all from one app.", "Applications", "bigboss", "folder.fill", 0xFF9F0A, 12400, [], "• Added 7z support\n• Text editor now supports syntax highlighting", ["File Browser", "Text Editor", "App Manager"]),
        p("ws.hbang.newterm3", "NewTerm 3", "3.0", "Hashbang Productions", "A full terminal in your pocket", "NewTerm 3 is a complete terminal emulator for iOS with tabs, custom fonts and full keyboard support.", "Utilities", "bigboss", "terminal.fill", 0x2C2C2E, 2600, [], "• Added tab support\n• Improved keyboard handling", ["Terminal", "Tabs"]),
        p("com.ivanobilenchi.icleanerpro", "iCleaner Pro", "7.10.0", "Ivano Bilenchi", "Clean up junk and free space", "iCleaner Pro removes caches, temporary files and unused data to free up storage and speed up your device.", "Utilities", "bigboss", "trash.fill", 0x32ADE6, 1800, [], "• Faster cache scanning\n• Added new cleanup targets", ["Cleanup", "Storage"]),
        p("com.dhowett.cocoatop64", "CocoaTop64", "2.2.2", "Dustin Howett", "Process monitor and task manager", "See what is running on your device in real time — CPU, memory and per-process details, just like top on the desktop.", "Utilities", "bigboss", "waveform.path.ecg", 0xAF52DE, 900, [], "• Added per-process details\n• Fixed refresh rate", ["Processes", "CPU Graph"]),
        p("org.coolstar.libcscolorpicker", "libCSColorPicker", "1.0.5", "CoolStar", "Color picker library", "libCSColorPicker provides a modern color picker for tweaks and apps that need color selection.", "Developer", "procursus", "eyedropper.fill", 0x0A84FF, 210, [], "• Minor bug fixes", []),
    ]
}
