import SwiftUI

struct QueueView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            if let j = store.job {
                VStack(spacing: 0) {
                    switch j.phase {
                    case .confirm: confirm(j)
                    case .running, .done: progress(j)
                    }
                }
                .navigationTitle(title(j))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if j.phase == .confirm {
                        ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { close() } }
                    }
                }
                .interactiveDismissDisabled(j.phase == .running)
            }
        }
        .presentationDetents([.large])
    }

    private func title(_ j: Job) -> String {
        switch j.phase { case .confirm: return "Queue"; case .running: return "\(j.op.rawValue)ing"; case .done: return "Done" }
    }
    private func close() { store.job = nil }

    private func confirm(_ j: Job) -> some View {
        VStack(spacing: 0) {
            List {
                Section("Will \(j.op.rawValue)") { ForEach(j.pkgs) { r($0) } }
                if !j.deps.isEmpty { Section("Dependencies (auto-installed)") { ForEach(j.deps) { r($0) } } }
                Section {
                    let kb = (j.pkgs + j.deps).reduce(0) { $0 + $1.size }
                    HStack {
                        Text(j.op == .remove ? "Free Space" : "Download Size").foregroundStyle(.secondary)
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: Int64(kb) * 1024, countStyle: .file))
                    }
                }
            }
            Button { store.run() } label: {
                Text("Confirm").font(.system(size: 17, weight: .bold)).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(j.op == .remove ? Color.red : Color.sileoTint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(16)
        }
    }

    private func r(_ p: Pkg) -> some View {
        HStack(spacing: 12) {
            PkgIcon(symbol: p.symbol, color: p.color, size: 36)
            Text(p.name); Spacer(); Text(p.version).foregroundStyle(.secondary)
        }
    }

    private func progress(_ j: Job) -> some View {
        VStack(spacing: 14) {
            ProgressView(value: j.progress).tint(.sileoTint).padding(.horizontal, 16).padding(.top, 16)
            Text("\(Int(j.progress * 100))%").font(.system(size: 13, weight: .medium).monospacedDigit()).foregroundStyle(.secondary)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(j.lines.enumerated()), id: \.offset) { i, l in
                            Text(l).font(.system(size: 12, design: .monospaced)).id(i)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(12)
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 16)
                .onChange(of: j.lines.count) { n in withAnimation { proxy.scrollTo(n - 1, anchor: .bottom) } }
            }
            if j.phase == .done {
                Button { close() } label: {
                    Text("Done").font(.system(size: 17, weight: .bold)).frame(maxWidth: .infinity).padding(.vertical, 14)
                        .foregroundStyle(.white).background(Color.sileoTint, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: j.phase)
    }
}
