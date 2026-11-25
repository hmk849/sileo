import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $store.appearance) {
                        Text("System").tag(0); Text("Light").tag(1); Text("Dark").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Sources") {
                    Toggle("Auto Refresh on Launch", isOn: $store.autoRefresh)
                    LabeledContent("Sources", value: "\(store.repos.count)")
                }
                Section("Data") {
                    NavigationLink("Activity Log") { LogView() }
                    Button("Clear Search History") { store.history = [] }
                    Button("Reset Demo Data", role: .destructive) { confirmReset = true }
                }
                Section("About") {
                    LabeledContent("Version", value: "2.5.1")
                    LabeledContent("Language", value: "English")
                    Text("Sileo is a modern APT package manager. Interface simulation — sources, packages and installs in this app are local mock data and never modify the system.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } } }
            .alert("Reset all demo data?", isPresented: $confirmReset) {
                Button("Reset", role: .destructive) { store.reset() }
                Button("Cancel", role: .cancel) {}
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
        .navigationTitle("Activity Log")
        .toolbar { Button("Clear") { store.logs = [] } }
    }
}
