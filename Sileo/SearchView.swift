import SwiftUI

struct SearchView: View {
    @EnvironmentObject var store: Store
    @State private var q = ""
    @State private var section: String?

    var results: [Pkg] {
        store.packages.filter { p in
            (section == nil || p.section == section) &&
            (q.isEmpty || p.name.localizedCaseInsensitiveContains(q) || p.summary.localizedCaseInsensitiveContains(q)
             || p.author.localizedCaseInsensitiveContains(q) || p.id.localizedCaseInsensitiveContains(q))
        }
        .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            chip("All", nil)
                            ForEach(Catalog.sections, id: \.self) { chip($0, $0) }
                        }
                        .padding(.horizontal, 16)
                    }
                    .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
                }
                if q.isEmpty && !store.history.isEmpty {
                    Section {
                        ForEach(store.history, id: \.self) { h in
                            Button { q = h } label: {
                                Label(h, systemImage: "clock").foregroundStyle(.primary)
                            }
                        }
                    } header: {
                        HStack {
                            Text("Recently Searched")
                            Spacer()
                            Button("Clear") { store.history = [] }.font(.footnote)
                        }
                    }
                }
                Section(q.isEmpty ? "All Packages" : "Results (\(results.count))") {
                    ForEach(results) { p in NavigationLink(value: p) { PkgRow(p: p) } }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $q, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for Packages")
            .onSubmit(of: .search) { store.addHistory(q) }
            .overlay {
                if results.isEmpty { Text("No packages found").foregroundStyle(.secondary) }
            }
            .sileoDestinations()
        }
    }

    private func chip(_ title: String, _ value: String?) -> some View {
        let on = section == value
        return Button { withAnimation(.spring(response: 0.3)) { section = value } } label: {
            Text(title).font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 14).padding(.vertical, 7)
                .foregroundStyle(on ? Color.white : Color.primary)
                .background(on ? Color.sileoTint : Color(.secondarySystemFill), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
