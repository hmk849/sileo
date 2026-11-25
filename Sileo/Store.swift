import SwiftUI

@MainActor
final class Store: ObservableObject {
    private struct Saved: Codable {
        var repos: [Repo]
        var installed: [String: String]
        var history: [String]
        var logs: [LogEntry]
        var appearance: Int
        var autoRefresh: Bool
    }

    private let key = "sileo.state.v1"

    @Published var repos: [Repo] { didSet { save() } }
    @Published var installed: [String: String] { didSet { save() } }
    @Published var history: [String] { didSet { save() } }
    @Published var logs: [LogEntry] { didSet { save() } }
    @Published var appearance: Int { didSet { save() } }      // 0 系统 1 浅色 2 深色
    @Published var autoRefresh: Bool { didSet { save() } }
    @Published var job: Job?

    init() {
        if let d = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(Saved.self, from: d) {
            repos = s.repos; installed = s.installed; history = s.history
            logs = s.logs; appearance = s.appearance; autoRefresh = s.autoRefresh
        } else {
            repos = Catalog.repos
            installed = Self.seedInstalled
            history = []
            logs = [LogEntry(text: "欢迎使用 Sileo（模拟环境）")]
            appearance = 0
            autoRefresh = true
        }
    }

    private static let seedInstalled = [
        "org.core.libswift": "5.9.0", "org.core.substrate": "0.4.2",
        "com.lumen.dimmer": "2.3.0", "com.hack.netmon": "1.5.0",
    ]

    private func save() {
        let s = Saved(repos: repos, installed: installed, history: history, logs: logs,
                      appearance: appearance, autoRefresh: autoRefresh)
        if let d = try? JSONEncoder().encode(s) { UserDefaults.standard.set(d, forKey: key) }
    }

    var scheme: ColorScheme? {
        switch appearance { case 1: return .light; case 2: return .dark; default: return nil }
    }

    // MARK: 数据查询
    var packages: [Pkg] {
        Catalog.all.filter { p in repos.contains { $0.enabled && $0.id == p.repo } }
    }
    var installedPkgs: [Pkg] { packages.filter { installed[$0.id] != nil } }
    var updates: [Pkg] { installedPkgs.filter { installed[$0.id] != $0.version } }

    func repoName(_ id: String) -> String { repos.first { $0.id == id }?.name ?? "未知软件源" }
    func count(in repo: Repo) -> Int { Catalog.all.filter { $0.repo == repo.id }.count }

    // MARK: 软件源管理
    func addRepo(url: String) {
        let host = URL(string: url)?.host ?? url
        repos.append(Repo(id: UUID().uuidString, name: host, url: url, desc: "自定义软件源",
                          symbol: "shippingbox.fill", color: 0x636366))
        log("添加软件源 \(url)")
    }
    func update(_ r: Repo) {
        if let i = repos.firstIndex(where: { $0.id == r.id }) { repos[i] = r; log("编辑软件源 \(r.name)") }
    }
    func removeRepos(at offsets: IndexSet) {
        for i in offsets { log("删除软件源 \(repos[i].name)") }
        repos.remove(atOffsets: offsets)
    }

    // MARK: 搜索历史 / 日志
    func addHistory(_ q: String) {
        let t = q.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty else { return }
        history.removeAll { $0 == t }
        history.insert(t, at: 0)
        history = Array(history.prefix(10))
    }
    func log(_ text: String) {
        logs.append(LogEntry(text: text))
        if logs.count > 200 { logs.removeFirst(logs.count - 200) }
    }
    func refresh() { log("已刷新 \(repos.filter(\.enabled).count) 个软件源") }

    func reset() {
        repos = Catalog.repos; installed = Self.seedInstalled; history = []
        logs = [LogEntry(text: "已重置模拟数据")]
    }

    // MARK: 模拟安装 / 卸载 / 更新
    func prepare(_ op: Op, _ pkgs: [Pkg]) {
        var deps: [Pkg] = []
        if op != .remove {
            for p in pkgs {
                for d in p.depends where installed[d] == nil
                    && !pkgs.contains(where: { $0.id == d }) && !deps.contains(where: { $0.id == d }) {
                    if let dp = Catalog.pkg(d) { deps.append(dp) }
                }
            }
        }
        job = Job(op: op, pkgs: pkgs, deps: deps)
    }

    func run() {
        guard let j = job, j.phase == .confirm else { return }
        job?.phase = .running
        let op = j.op
        let all = j.deps + j.pkgs
        Task {
            let total = max(all.count * 3, 1)
            var n = 0
            for p in all {
                let stages = op == .remove
                    ? ["正在准备卸载 \(p.name)…", "正在移除文件…", "正在清理配置…"]
                    : ["正在下载 \(p.name) (\(p.version))…", "正在解压…", "正在配置 \(p.name)…"]
                for s in stages {
                    job?.lines.append(s)
                    n += 1
                    withAnimation(.easeOut(duration: 0.3)) { job?.progress = Double(n) / Double(total) }
                    try? await Task.sleep(nanoseconds: 450_000_000)
                }
                if op == .remove { installed[p.id] = nil } else { installed[p.id] = p.version }
                job?.lines.append("✓ \(op.rawValue)完成：\(p.name)")
                log("\(op.rawValue) \(p.name) \(p.version)")
            }
            job?.lines.append("所有操作已完成（模拟）。")
            job?.phase = .done
        }
    }
}
