import SwiftUI

struct DashboardView: View {
    @State private var blockerVM = BlockerViewModel()
    @State private var syncVM = SyncViewModel()
    @State private var statsVM = StatsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    protectionCard
                    statsGrid
                    healthCard
                    syncCard
                }
                .padding()
            }
            .navigationTitle("SpamSentry")
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .task {
            blockerVM.loadState()
            syncVM.loadState()
            statsVM.loadStats()
            await blockerVM.checkHealth()
        }
        .refreshable {
            await blockerVM.checkHealth()
            statsVM.loadStats()
        }
    }

    private var protectionCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        blockerVM.isEnabled && !blockerVM.isPaused
                        ? Color.green.opacity(0.15)
                        : Color.orange.opacity(0.15)
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: blockerVM.isPaused ? "shield.slash" : "shield.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        blockerVM.isEnabled && !blockerVM.isPaused ? .green : .orange
                    )
            }

            Text(blockerVM.isPaused ? "Protection Paused" : blockerVM.isEnabled ? "Protection Active" : "Protection Disabled")
                .font(.title2.bold())

            Text("\(SpamSentryShared.blockedNumberCount) numbers blocked")
                .foregroundStyle(.secondary)

            if blockerVM.isPaused {
                Button("Resume Protection") {
                    blockerVM.resumeBlocking()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Total Blocked", value: "\(statsVM.totalBlocked)", icon: "phone.badge.xmark", color: .red)
            StatCard(title: "Today", value: "\(statsVM.todayBlocked)", icon: "calendar", color: .blue)
            StatCard(title: "Community DB", value: "\(statsVM.communityCount)", icon: "person.3.fill", color: .green)
            StatCard(title: "Custom", value: "\(statsVM.customCount)", icon: "plus.circle.fill", color: .orange)
        }
    }

    private var healthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.circle")
                    .foregroundStyle(healthColor)
                Text("Extension Health")
                    .font(.headline)
                Spacer()
                Text(healthLabel)
                    .font(.caption)
                    .foregroundStyle(healthColor)
            }

            if case .stale(let date) = blockerVM.healthStatus {
                Text("Last loaded: \(date.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if case .failed(let error) = blockerVM.healthStatus {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            HStack(spacing: 12) {
                Button {
                    Task { await blockerVM.repairExtension() }
                } label: {
                    Label("Repair", systemImage: "wrench.and.screwdriver")
                        .font(.caption)
                }
                .buttonStyle(.bordered)

                Button {
                    Task { await blockerVM.reloadExtension() }
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var syncCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                Text("Blocklist Sync")
                    .font(.headline)
                Spacer()
                if syncVM.isSyncing {
                    ProgressView()
                }
            }

            if let date = syncVM.lastSyncDate {
                Text("Last sync: \(date.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = syncVM.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await syncVM.syncBlocklist() }
            } label: {
                Label("Sync Now", systemImage: "arrow.down.circle")
            }
            .buttonStyle(.bordered)
            .disabled(syncVM.isSyncing)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var healthColor: Color {
        switch blockerVM.healthStatus {
        case .healthy: return .green
        case .stale: return .orange
        case .failed: return .red
        case .disabled: return .gray
        case .unknown: return .yellow
        }
    }

    private var healthLabel: String {
        switch blockerVM.healthStatus {
        case .healthy: return "Healthy"
        case .stale: return "Stale"
        case .failed: return "Failed"
        case .disabled: return "Disabled"
        case .unknown: return "Unknown"
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
}
