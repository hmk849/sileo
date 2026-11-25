import SwiftUI

struct DetailView: View {
    @EnvironmentObject var store: Store
    let p: Pkg

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 16) {
                    PkgIcon(symbol: p.symbol, color: p.color, size: 84)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.name).font(.system(size: 22, weight: .bold))
                        Text(p.author).font(.system(size: 14)).foregroundStyle(Color.sileoTint)
                        Text("Version \(p.version)").font(.system(size: 13)).foregroundStyle(.secondary)
                        HStack(spacing: 8) { buttons }.padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)

                if !p.shots.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(p.shots, id: \.self) { s in
                                ZStack(alignment: .bottom) {
                                    LinearGradient(colors: [Color(hex: p.color), Color(hex: p.color).opacity(0.5)],
                                                   startPoint: .top, endPoint: .bottom)
                                    Image(systemName: p.symbol)
                                        .font(.system(size: 64, weight: .bold)).foregroundStyle(.white.opacity(0.85))
                                        .frame(maxHeight: .infinity)
                                    Text(s).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6).glass(12).padding(10)
                                }
                                .frame(width: 150, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                card("Description") { Text(p.details).font(.system(size: 15)) }
                card("Changelog") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Version \(p.version)").font(.system(size: 13, weight: .semibold))
                        Text(p.changelog).font(.system(size: 14)).foregroundStyle(.secondary)
                    }
                }
                if !p.depends.isEmpty {
                    card("Dependencies") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(p.depends, id: \.self) { d in
                                HStack {
                                    Text(Catalog.pkg(d)?.name ?? d).font(.system(size: 15))
                                    Spacer()
                                    Text(store.installed[d] != nil ? "Installed" : "Will be installed automatically")
                                        .font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                card("Details") {
                    VStack(spacing: 10) {
                        row("Package ID", p.id); row("Version", p.version)
                        row("Size", ByteCountFormatter.string(fromByteCount: Int64(p.size) * 1024, countStyle: .file))
                        row("Section", p.section); row("Source", store.repoName(p.repo)); row("Author", p.author)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private var buttons: some View {
        if let iv = store.installed[p.id] {
            if iv != p.version { GetButton(title: "Upgrade") { store.prepare(.update, [p]) } }
            GetButton(title: "Uninstall", destructive: true) { store.prepare(.remove, [p]) }
        } else {
            GetButton(title: "Get") { store.prepare(.install, [p]) }
        }
    }

    private func card<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(size: 18, weight: .bold))
            content().frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, 16)
    }

    private func row(_ k: String, _ v: String) -> some View {
        HStack { Text(k).foregroundStyle(.secondary); Spacer(); Text(v).multilineTextAlignment(.trailing) }
            .font(.system(size: 14))
    }
}
