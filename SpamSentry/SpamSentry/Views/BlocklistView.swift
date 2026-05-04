import SwiftUI

struct BlocklistView: View {
    @State private var blockedNumbers: [BlockedNumberItem] = []
    @State private var showingAddSheet = false
    @State private var newNumber = ""
    @State private var newLabel = ""
    @State private var filterSource: String = "All"

    var body: some View {
        NavigationStack {
            List {
                Picker("Source", selection: $filterSource) {
                    Text("All").tag("All")
                    Text("Community").tag("community")
                    Text("Custom").tag("custom")
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)

                ForEach(filteredNumbers) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.displayNumber)
                                .font(.body.monospaced())
                            if let label = item.label {
                                Text(label)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(item.source)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(item.source == "community" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteNumber(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Blocklist")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                addNumberSheet
            }
            .task { loadNumbers() }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }

    private var filteredNumbers: [BlockedNumberItem] {
        if filterSource == "All" { return blockedNumbers }
        return blockedNumbers.filter { $0.source == filterSource }
    }

    private var addNumberSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Phone Number", text: $newNumber)
                        .keyboardType(.phonePad)
                    TextField("Label (optional)", text: $newLabel)
                } header: {
                    Text("Add Number to Blocklist")
                }
            }
            .navigationTitle("Block Number")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingAddSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addNumber() }
                        .disabled(newNumber.isEmpty)
                }
            }
        }
    }

    private func loadNumbers() {
        let db = BlocklistDatabase.shared
        let community = db.fetchBlockedNumbers(source: .community).map {
            BlockedNumberItem(id: $0.id, number: $0.number, label: $0.label, source: "community", addedAt: $0.addedAt)
        }
        let custom = db.fetchBlockedNumbers(source: .custom).map {
            BlockedNumberItem(id: $0.id, number: $0.number, label: $0.label, source: "custom", addedAt: $0.addedAt)
        }
        blockedNumbers = (community + custom).sorted { $0.addedAt > $1.addedAt }
    }

    private func addNumber() {
        let digits = newNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let number = Int64(digits), !digits.isEmpty else { return }

        let db = BlocklistDatabase.shared
        db.addBlockedNumber(number, label: newLabel.isEmpty ? nil : newLabel, source: .custom)

        var custom = SpamSentryShared.customBlocklist
        custom.append(number)
        SpamSentryShared.customBlocklist = custom

        newNumber = ""
        newLabel = ""
        showingAddSheet = false
        loadNumbers()
    }

    private func deleteNumber(_ item: BlockedNumberItem) {
        let db = BlocklistDatabase.shared
        db.removeBlockedNumber(item.number)

        if item.source == "custom" {
            var custom = SpamSentryShared.customBlocklist
            custom.removeAll { $0 == item.number }
            SpamSentryShared.customBlocklist = custom
        }

        loadNumbers()
    }
}

#Preview {
    BlocklistView()
}
