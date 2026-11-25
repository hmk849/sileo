import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        TabView {
            HomeView().tabItem { Label("精选", systemImage: "sparkles") }
            SourcesView().tabItem { Label("软件源", systemImage: "square.stack.3d.up.fill") }
            ChangesView().tabItem { Label("更改", systemImage: "clock.arrow.circlepath") }
                .badge(store.updates.count)
            InstalledView().tabItem { Label("已安装", systemImage: "shippingbox.fill") }
            SearchView().tabItem { Label("搜索", systemImage: "magnifyingglass") }
        }
        .sheet(item: $store.job) { _ in QueueView() }
    }
}

extension View {
    func sileoDestinations() -> some View {
        self
            .navigationDestination(for: Pkg.self) { DetailView(p: $0) }
            .navigationDestination(for: Repo.self) { RepoDetailView(repo: $0) }
            .navigationDestination(for: String.self) { SectionListView(section: $0) }
    }
}

struct PkgRow: View {
    @EnvironmentObject var store: Store
    let p: Pkg

    var body: some View {
        HStack(spacing: 12) {
            PkgIcon(symbol: p.symbol, color: p.color, size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(p.name).font(.system(size: 16, weight: .semibold)).lineLimit(1)
                Text(p.summary).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(1)
                Text("\(p.author) · \(p.version)").font(.system(size: 12)).foregroundStyle(.tertiary)
            }
            Spacer(minLength: 4)
            if store.installed[p.id] != nil {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.sileoTint)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: 精选
struct HomeView: View {
    @EnvironmentObject var store: Store
    @State private var showSettings = false
    @State private var seed = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Catalog.featured) { f in
                                if let p = Catalog.pkg(f.pkg) {
                                    NavigationLink(value: p) { FeaturedCard(f: f) }.buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        header("分类")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(Catalog.sections, id: \.self) { s in
                                NavigationLink(value: s) {
                                    HStack {
                                        Text(s).font(.system(size: 16, weight: .medium))
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.tertiary)
                                    }
                                    .padding(14)
                                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        header("推荐软件包")
                        let list = Array(store.packages.shuffled(seed: seed).prefix(6))
                        ForEach(list) { p in
                            NavigationLink(value: p) { PkgRow(p: p).padding(.horizontal, 16).padding(.vertical, 8) }
                                .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, 8).padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("精选")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: { Image(systemName: "gearshape.fill") }
                }
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 900_000_000)
                store.refresh(); seed += 1
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sileoDestinations()
        }
    }

    private func header(_ t: String) -> some View {
        Text(t).font(.system(size: 22, weight: .bold)).padding(.horizontal, 16)
    }
}

extension Array {
    func shuffled(seed: Int) -> [Element] {
        var g = SeededRNG(state: UInt64(truncatingIfNeeded: seed) &+ 0x9E3779B97F4A7C15)
        return shuffled(using: &g)
    }
}
struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

struct FeaturedCard: View {
    let f: Featured
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(hex: f.c1), Color(hex: f.c2)], startPoint: .topLeading, endPoint: .bottomTrailing)
            Image(systemName: f.symbol)
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(.white.opacity(0.22))
                .offset(x: 120, y: -50)
            VStack(alignment: .leading, spacing: 3) {
                Text(f.title).font(.system(size: 19, weight: .bold))
                Text(f.subtitle).font(.system(size: 13)).opacity(0.9)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14).padding(.vertical, 10)
            .glass(16)
            .padding(12)
        }
        .frame(width: 310, height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

// MARK: 分类 / 列表
struct SectionListView: View {
    @EnvironmentObject var store: Store
    let section: String

    var items: [Pkg] {
        store.packages.filter { section == "__all" || $0.section == section }.sorted { $0.name < $1.name }
    }

    var body: some View {
        List(items) { p in
            NavigationLink(value: p) { PkgRow(p: p) }
        }
        .listStyle(.plain)
        .navigationTitle(section == "__all" ? "全部软件包" : section)
        .navigationBarTitleDisplayMode(.inline)
        .overlay { if items.isEmpty { Text("暂无软件包").foregroundStyle(.secondary) } }
    }
}
