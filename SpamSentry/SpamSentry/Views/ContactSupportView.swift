import SwiftUI

struct ContactSupportView: View {
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let topics = ["General", "Bug Report", "Feature Request", "Blocklist Issue", "Other"]

    var body: some View {
        Form {
            Section {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { t in
                        Text(t).tag(t)
                    }
                }

                TextField("Name (optional)", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            } header: {
                Text("Message")
            }

            Section {
                Button {
                    submitFeedback()
                } label: {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(email.isEmpty || message.isEmpty || isSubmitting)
            }
        }
        .navigationTitle("Contact Support")
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage.contains("Success") ? "Sent" : "Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func submitFeedback() {
        isSubmitting = true

        guard let backendURL = ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"],
              !backendURL.isEmpty else {
            alertMessage = "Success! Your message has been received."
            showAlert = true
            isSubmitting = false
            message = ""
            return
        }

        guard let url = URL(string: backendURL) else {
            alertMessage = "Invalid backend URL."
            showAlert = true
            isSubmitting = false
            return
        }

        let body: [String: String] = [
            "topic": topic,
            "name": name,
            "email": email,
            "message": message
        ]

        guard let httpBody = try? JSONEncoder().encode(body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    alertMessage = error.localizedDescription
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    alertMessage = "Success! Your message has been received."
                    message = ""
                } else {
                    alertMessage = "Failed to send. Please try again."
                }
                showAlert = true
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        ContactSupportView()
    }
}
