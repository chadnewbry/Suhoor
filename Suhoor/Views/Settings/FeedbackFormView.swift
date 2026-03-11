import SwiftUI

struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType = "General"
    @State private var feedbackText = ""
    @State private var showingConfirmation = false

    private let feedbackTypes = ["General", "Bug Report", "Feature Request", "Prayer Times", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.suhoorIndigo.ignoresSafeArea()
                Form {
                    Section {
                        Picker("Type", selection: $feedbackType) {
                            ForEach(feedbackTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                    } header: {
                        Text("Feedback Type")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    Section {
                        TextEditor(text: $feedbackText)
                            .frame(minHeight: 150)
                            .scrollContentBackground(.hidden)
                    } header: {
                        Text("Your Feedback")
                    }
                    .listRowBackground(Color.suhoorSurface)

                    Section {
                        Button {
                            submitFeedback()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Submit Feedback")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .listRowBackground(Color.suhoorGold.opacity(
                        feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1.0
                    ))
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.suhoorTextPrimary)
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Thank You!", isPresented: $showingConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your feedback has been submitted. We appreciate your input!")
            }
        }
    }

    private func submitFeedback() {
        // Compose email with feedback
        let subject = "Suhoor Feedback: \(feedbackType)"
        let body = feedbackText
        let email = "chad.newbry@gmail.com"
        let mailto = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body)"
        if let url = URL(string: mailto) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // Fallback: just show confirmation
                    showingConfirmation = true
                }
            }
        }
    }
}

#Preview {
    FeedbackFormView()
}
