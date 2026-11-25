import SwiftUI

struct NewsView: View {
    @EnvironmentObject var store: Store

    var recent: [(Pkg, String)] {
        let days = ["Today", "Today", "Yesterday", "Yesterday", "2 days ago", "3 days ago", "5 days ago", "1 week ago"]
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
                            Text("Available Updates (\(store.updates.count))")
                            Spacer()
                            Button("Update All") { store.prepare(.update, store.updates) }
                                .font(.footnote.bold())
                        }
                    }
                }
                Section("Recently Updated") {
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
            .navigationTitle("News")
            .refreshable {
                try? await Task.sleep(nanoseconds: 900_000_000)
                store.refresh()
            }
            .sileoDestinations()
        }
    }
}
