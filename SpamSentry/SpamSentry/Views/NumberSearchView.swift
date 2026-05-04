import SwiftUI

struct NumberSearchView: View {
    @State private var searchText = ""
    @State private var results: [BlockedNumberItem] = []

    var body: some View {
        NavigationStack {
            List(results) { item in
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
            }
            .navigationTitle("Search Numbers")
            .searchable(text: $searchText, prompt: "Enter phone number")
            .onChange(of: searchText) { _, newValue in
                searchNumbers(newValue)
            }
            .overlay {
                if results.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView(
                        "Not Found",
                        systemImage: "phone.badge.xmark",
                        description: Text("This number is not in the blocklist")
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
    }

    private func searchNumbers(_ query: String) {
        let digits = query.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard digits.count >= 3 else {
            results = []
            return
        }

        let db = BlocklistDatabase.shared
        let found = db.searchNumber(digits)
        results = found.map {
            BlockedNumberItem(
                id: $0.id,
                number: $0.number,
                label: $0.label,
                source: $0.source.rawValue,
                addedAt: $0.addedAt
            )
        }
    }
}

#Preview {
    NumberSearchView()
}
