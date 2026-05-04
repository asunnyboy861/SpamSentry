import SwiftUI

struct SettingsView: View {
    @State private var blockerVM = BlockerViewModel()
    @State private var areaCodeText = ""
    @State private var areaCodeRules: [String] = []

    private let supportURL = "https://asunnyboy861.github.io/SpamSentry/support.html"
    private let privacyURL = "https://asunnyboy861.github.io/SpamSentry/privacy.html"

    var body: some View {
        NavigationStack {
            Form {
                protectionSection
                pauseSection
                areaCodeSection
                aboutSection
            }
            .navigationTitle("Settings")
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .task {
                blockerVM.loadState()
                areaCodeRules = SpamSentryShared.areaCodeRules
            }
        }
    }

    private var protectionSection: some View {
        Section {
            Toggle("Enable Call Blocking", isOn: $blockerVM.isEnabled)
                .onChange(of: blockerVM.isEnabled) { _, newValue in
                    SpamSentryShared.isEnabled = newValue
                }

            Button {
                blockerVM.openPhoneSettings()
            } label: {
                HStack {
                    Text("Configure in Phone Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                Task { await blockerVM.reloadExtension() }
            } label: {
                HStack {
                    Text("Reload Extension")
                    if blockerVM.isLoading {
                        Spacer()
                        ProgressView()
                    }
                }
            }
        } header: {
            Text("Protection")
        }
    }

    private var pauseSection: some View {
        Section {
            if blockerVM.isPaused {
                Button("Resume Protection Now") {
                    blockerVM.resumeBlocking()
                }
                .foregroundStyle(.green)
            } else {
                HStack {
                    Button("Pause 15 min") { blockerVM.pauseBlocking(minutes: 15) }
                    Button("Pause 30 min") { blockerVM.pauseBlocking(minutes: 30) }
                    Button("Pause 1 hour") { blockerVM.pauseBlocking(minutes: 60) }
                }
                .buttonStyle(.bordered)
            }
        } header: {
            Text("Temporary Pause")
        } footer: {
            Text("Pause blocking when expecting calls from unknown numbers")
        }
    }

    private var areaCodeSection: some View {
        Section {
            HStack {
                TextField("Area code (e.g. 800)", text: $areaCodeText)
                    .keyboardType(.numberPad)
                Button("Add") {
                    addAreaCode()
                }
                .disabled(areaCodeText.isEmpty)
            }

            ForEach(areaCodeRules, id: \.self) { code in
                HStack {
                    Text(code)
                    Spacer()
                    Button {
                        removeAreaCode(code)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        } header: {
            Text("Area Code Blocking")
        } footer: {
            Text("Block all numbers starting with these area codes")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }

            Link("Support Page", destination: URL(string: supportURL)!)
            Link("Privacy Policy", destination: URL(string: privacyURL)!)

            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }

    private func addAreaCode() {
        let digits = areaCodeText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard !digits.isEmpty && !areaCodeRules.contains(digits) else { return }
        areaCodeRules.append(digits)
        SpamSentryShared.areaCodeRules = areaCodeRules
        areaCodeText = ""
    }

    private func removeAreaCode(_ code: String) {
        areaCodeRules.removeAll { $0 == code }
        SpamSentryShared.areaCodeRules = areaCodeRules
    }
}

#Preview {
    SettingsView()
}
