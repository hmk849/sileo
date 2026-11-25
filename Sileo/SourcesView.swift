import SwiftUI

struct SourcesView: View {
    @EnvironmentObject var store: Store
    @State private var adding = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: "__all") {
                        HStack(spacing: 12) {
                            PkgIcon(symbol: "tray.full.fill", color: 0x7C5CFF, size: 40)
                            Text("全部软件包").font(.system(size: 16, weight: .medium))
                            Spacer()
                            Text("\(store.packages.count)").foregroundStyle(.secondary)
                        }
                    }
                }
                Section("软件源") {
                    ForEach(store.repos) { r in
                        NavigationLink(value: r) {
                            HStack(spacing: 12) {
                                PkgIcon(symbol: r.symbol, color: r.color, size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(r.name).font(.system(size: 16, weight: .medium))
                                    Text(r.url).font(.system(size: 12)).foregroundStyle(.secondary).lineLimit(1)
                                }
                                Spacer()
                                if !r.enabled { Text("已停用").font(.caption).foregroundStyle(.secondary) }
                            }
                        }
                        .deleteDisabled(r.isDefault)
                    }
                    .onDelete { store.removeRepos(at: $0) }
                    .onMove { store.repos.move(fromOffsets: $0, toOffset: $1) }
                }
            }
            .navigationTitle("软件源")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { adding = true } label: { Image(systemName: "plus") }
                }
            }
            .refreshable {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                store.refresh()
            }
            .sheet(isPresented: $adding) { AddRepoView() }
            .sileoDestinations()
        }
    }
}

struct RepoDetailView: View {
    @EnvironmentObject var store: Store
    let repo: Repo
    @State private var editing = false

    // 编辑后展示最新数据
    var current: Repo { store.repos.first { $0.id == repo.id } ?? repo }
    var items: [Pkg] { Catalog.all.filter { $0.repo == repo.id } }

    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    PkgIcon(symbol: current.symbol, color: current.color, size: 60)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(current.name).font(.system(size: 20, weight: .bold))
                        Text(current.desc).font(.system(size: 13)).foregroundStyle(.secondary)
                        Text(current.url).font(.system(size: 11)).foregroundStyle(.tertiary).lineLimit(1)
                    }
                }
                .padding(.vertical, 4)
            }
            Section("软件包（\(items.count)）") {
                if items.isEmpty { Text("此源暂无软件包（模拟）").foregroundStyle(.secondary) }
                ForEach(items) { p in NavigationLink(value: p) { PkgRow(p: p) } }
            }
        }
        .navigationTitle(current.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { Button("编辑") { editing = true } }
        .sheet(isPresented: $editing) { EditRepoView(repo: current) }
    }
}

struct AddRepoView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var url = "https://"
    @State private var loading = false

    var valid: Bool { url.hasPrefix("http") && URL(string: url)?.host != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(footer: Text("输入软件源地址，例如 https://repo.example.com/")) {
                    TextField("https://", text: $url)
                        .textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                }
                if loading {
                    HStack { ProgressView(); Text("正在验证软件源…").foregroundStyle(.secondary) }
                }
            }
            .navigationTitle("添加软件源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        Task {
                            loading = true
                            try? await Task.sleep(nanoseconds: 1_200_000_000)
                            store.addRepo(url: url)
                            dismiss()
                        }
                    }
                    .disabled(!valid || loading)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct EditRepoView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State var repo: Repo

    var body: some View {
        NavigationStack {
            Form {
                Section("名称") { TextField("名称", text: $repo.name) }
                Section("地址") {
                    TextField("https://", text: $repo.url)
                        .textInputAutocapitalization(.never).autocorrectionDisabled().keyboardType(.URL)
                }
                Section { Toggle("启用此软件源", isOn: $repo.enabled) }
            }
            .navigationTitle("编辑软件源")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { store.update(repo); dismiss() }
                        .disabled(repo.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
