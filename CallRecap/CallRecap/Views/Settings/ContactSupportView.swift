import SwiftUI

struct ContactSupportView: View {
    @State private var selectedSubject: Subject = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    enum Subject: String, CaseIterable {
        case general = "General"
        case featureSuggestion = "Feature Suggestion"
        case bugReport = "Bug Report"
        case usageQuestion = "Usage Question"
        case performanceIssue = "Performance Issue"
        case uiImprovement = "UI Improvement"
        case other = "Other"

        var icon: String {
            switch self {
            case .general: return "message.fill"
            case .featureSuggestion: return "lightbulb.fill"
            case .bugReport: return "ladybug.fill"
            case .usageQuestion: return "questionmark.circle.fill"
            case .performanceIssue: return "gauge.with.dots.needle.33percent"
            case .uiImprovement: return "paintbrush.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    subjectSection
                    if selectedSubject == .other {
                        customSubjectField
                    }
                    nameField
                    emailField
                    messageField
                    submitButton
                }
                .padding()
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your feedback has been submitted successfully.")
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subject")
                .font(.headline)

            let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Subject.allCases, id: \.self) { subject in
                    Button {
                        selectedSubject = subject
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: subject.icon)
                                .font(.caption)
                            Text(subject.rawValue)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minWidth: 100)
                        .background(selectedSubject == subject ? Color.appPrimary : Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(selectedSubject == subject ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Custom Subject")
                .font(.subheadline.bold())
            TextField("Enter your subject", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Name")
                .font(.subheadline.bold())
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Email")
                .font(.subheadline.bold())
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Message")
                .font(.subheadline.bold())
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(4)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var submitButton: some View {
        Button {
            submitFeedback()
        } label: {
            if isSubmitting {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Submit")
                    .font(.headline)
            }
        }
        .primaryButtonStyle()
        .disabled(name.isEmpty || email.isEmpty || message.isEmpty)
    }

    private func submitFeedback() {
        isSubmitting = true
        errorMessage = nil

        let subjectText = selectedSubject == .other ? customSubject : selectedSubject.rawValue

        let body: [String: String] = [
            "name": name,
            "email": email,
            "subject": subjectText,
            "message": message,
            "app_name": "CallRecap"
        ]

        guard let url = URL(string: "\(backendURL)/api/feedback"),
              let httpBody = try? JSONEncoder().encode(body) else {
            errorMessage = "Failed to prepare request"
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    showSuccess = true
                } else {
                    errorMessage = "Server error. Please try again."
                }
            }
        }.resume()
    }
}
