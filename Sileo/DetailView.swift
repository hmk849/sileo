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
                        Text("版本 \(p.version)").font(.system(size: 13)).foregroundStyle(.secondary)
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

                card("描述") { Text(p.details).font(.system(size: 15)) }
                card("更新日志") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("版本 \(p.version)").font(.system(size: 13, weight: .semibold))
                        Text(p.changelog).font(.system(size: 14)).foregroundStyle(.secondary)
                    }
                }
                if !p.depends.isEmpty {
                    card("依赖") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(p.depends, id: \.self) { d in
                                HStack {
                                    Text(Catalog.pkg(d)?.name ?? d).font(.system(size: 15))
                                    Spacer()
                                    Text(store.installed[d] != nil ? "已安装" : "将自动安装")
                                        .font(.system(size: 12)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                card("详细信息") {
                    VStack(spacing: 10) {
                        row("软件包标识", p.id); row("版本", p.version)
                        row("大小", ByteCountFormatter.string(fromByteCount: Int64(p.size) * 1024, countStyle: .file))
                        row("分类", p.section); row("软件源", store.repoName(p.repo)); row("作者", p.author)
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
            if iv != p.version { GetButton(title: "更新") { store.prepare(.update, [p]) } }
            GetButton(title: "卸载", destructive: true) { store.prepare(.remove, [p]) }
        } else {
            GetButton(title: "获取") { store.prepare(.install, [p]) }
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
