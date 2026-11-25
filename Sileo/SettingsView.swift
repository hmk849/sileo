import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("外观") {
                    Picker("主题", selection: $store.appearance) {
                        Text("跟随系统").tag(0); Text("浅色").tag(1); Text("深色").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                Section("软件源") {
                    Toggle("启动时自动刷新", isOn: $store.autoRefresh)
                    LabeledContent("软件源数量", value: "\(store.repos.count)")
                }
                Section("数据") {
                    NavigationLink("操作日志") { LogView() }
                    Button("清除搜索历史") { store.history = [] }
                    Button("重置模拟数据", role: .destructive) { confirmReset = true }
                }
                Section("关于") {
                    LabeledContent("版本", value: "1.0 (模拟)")
                    LabeledContent("语言", value: "简体中文")
                    Text("本应用为 Sileo 的界面仿真，所有软件源、软件包与安装行为均为本地模拟，不会修改系统。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("完成") { dismiss() } } }
            .alert("重置所有模拟数据？", isPresented: $confirmReset) {
                Button("重置", role: .destructive) { store.reset() }
                Button("取消", role: .cancel) {}
            }
        }
    }
}

struct LogView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        List(store.logs.reversed()) { e in
            VStack(alignment: .leading, spacing: 2) {
                Text(e.text).font(.system(size: 14))
                Text(e.date.formatted(date: .abbreviated, time: .standard)).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("操作日志")
        .toolbar { Button("清空") { store.logs = [] } }
    }
}
