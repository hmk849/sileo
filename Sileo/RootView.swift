import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        TabView {
            FeaturedView()
                .tabItem { Label("Featured", systemImage: "star.fill") }
            NewsView()
                .tabItem { Label("News", systemImage: "newspaper.fill") }
                .badge(store.updates.count)
            PackagesView()
                .tabItem { Label("Packages", systemImage: "shippingbox.fill") }
            SourcesView()
                .tabItem { Label("Sources", systemImage: "square.stack.3d.up.fill") }
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
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
                Text("\(p.author) · \(p.version)").font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(1)
                Text(p.summary).font(.system(size: 12)).foregroundStyle(.tertiary).lineLimit(1)
            }
            Spacer(minLength: 4)
            if store.installed[p.id] != nil {
                if store.installed[p.id] != p.version {
                    GetButton(title: "Upgrade") { store.prepare(.update, [p]) }
                } else {
                    GetButton(title: "Modify") { store.prepare(.remove, [p]) }
                }
            } else {
                GetButton(title: "Get") { store.prepare(.install, [p]) }
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: Featured
struct FeaturedView: View {
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
                        header("Categories")
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
                        header("Recommended Packages")
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
            .navigationTitle("Featured")
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

// MARK: Packages tab
struct PackagesView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: "__all") {
                        HStack(spacing: 12) {
                            PkgIcon(symbol: "tray.full.fill", color: 0x2CB1BE, size: 40)
                            Text("All Packages").font(.system(size: 16, weight: .medium))
                            Spacer()
                            Text("\(store.packages.count)").foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink(value: "__installed") {
                        HStack(spacing: 12) {
                            PkgIcon(symbol: "shippingbox.fill", color: 0x34C759, size: 40)
                            Text("Installed Packages").font(.system(size: 16, weight: .medium))
                            Spacer()
                            Text("\(store.installedPkgs.count)").foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Categories") {
                    ForEach(Catalog.sections, id: \.self) { s in
                        NavigationLink(value: s) {
                            HStack(spacing: 12) {
                                PkgIcon(symbol: "folder.fill", color: 0x8E8E93, size: 40)
                                Text(s).font(.system(size: 16, weight: .medium))
                                Spacer()
                                Text("\(store.packages.filter { $0.section == s }.count)").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Packages")
            .refreshable {
                try? await Task.sleep(nanoseconds: 900_000_000)
                store.refresh()
            }
            .sileoDestinations()
        }
    }
}

// MARK: Category / list
struct SectionListView: View {
    @EnvironmentObject var store: Store
    let section: String

    var items: [Pkg] {
        switch section {
        case "__all": return store.packages.sorted { $0.name < $1.name }
        case "__installed": return store.installedPkgs.sorted { $0.name < $1.name }
        default: return store.packages.filter { $0.section == section }.sorted { $0.name < $1.name }
        }
    }

    var title: String {
        switch section {
        case "__all": return "All Packages"
        case "__installed": return "Installed Packages"
        default: return section
        }
    }

    var body: some View {
        List(items) { p in
            NavigationLink(value: p) { PkgRow(p: p) }
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay { if items.isEmpty { Text("No packages").foregroundStyle(.secondary) } }
    }
}
