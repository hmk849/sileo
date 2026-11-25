import SwiftUI

struct ChangesView: View {
    @EnvironmentObject var store: Store

    var recent: [(Pkg, String)] {
        let days = ["今天", "今天", "昨天", "昨天", "2 天前", "3 天前", "5 天前", "1 周前"]
        return store.packages.enumerated().map { ($0.element, days[$0.offset % days.count]) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !store.updates.isEmpty {
                    Section {
                        ForEach(store.updates) { p in
                            NavigationLink(value: p) {
                                HStack {
                                    PkgRow(p: p)
                                    Text("\(store.installed[p.id] ?? "") → \(p.version)")
                                        .font(.system(size: 11)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("可用更新（\(store.updates.count)）")
                            Spacer()
                            Button("全部更新") { store.prepare(.update, store.updates) }
                                .font(.footnote.bold())
                        }
                    }
                }
                Section("最近更新") {
                    ForEach(recent, id: \.0.id) { p, day in
                        NavigationLink(value: p) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    PkgIcon(symbol: p.symbol, color: p.color, size: 36)
                                    Text("\(p.name) \(p.version)").font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                    Text(day).font(.caption).foregroundStyle(.secondary)
                                }
                                Text(p.changelog).font(.system(size: 13)).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("更改")
            .refreshable {
                try? await Task.sleep(nanoseconds: 900_000_000)
                store.refresh()
            }
            .sileoDestinations()
        }
    }
}

struct InstalledView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.installedPkgs) { p in
                    NavigationLink(value: p) { PkgRow(p: p) }
                        .swipeActions {
                            Button("卸载", role: .destructive) { store.prepare(.remove, [p]) }
                        }
                }
            }
            .listStyle(.plain)
            .navigationTitle("已安装")
            .overlay {
                if store.installedPkgs.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox").font(.system(size: 44)).foregroundStyle(.tertiary)
                        Text("尚未安装任何软件包").foregroundStyle(.secondary)
                    }
                }
            }
            .sileoDestinations()
        }
    }
}
