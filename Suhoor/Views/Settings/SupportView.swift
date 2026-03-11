import SwiftUI
import StoreKit
import MessageUI

struct SupportView: View {
    @State private var showingFeedback = false
    @State private var showingShareSheet = false
    @State private var showingMailUnavailable = false
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        List {
            Section {
                Button {
                    sendSupportEmail()
                } label: {
                    Label("Customer Support", systemImage: "envelope")
                }

                Button {
                    requestReview()
                } label: {
                    Label("Rate the App", systemImage: "star")
                }

                Button {
                    showingShareSheet = true
                } label: {
                    Label("Share Suhoor", systemImage: "square.and.arrow.up")
                }

                Button {
                    showingFeedback = true
                } label: {
                    Label("Send Feedback", systemImage: "text.bubble")
                }
            } header: {
                Text("Get in Touch")
            }
            .listRowBackground(Color.suhoorSurface)
        }
        .scrollContentBackground(.hidden)
        .background(Color.suhoorIndigo)
        .foregroundStyle(.suhoorTextPrimary)
        .navigationTitle("Support")
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [
                "Check out Suhoor — a beautiful Ramadan companion app! 🌙",
                URL(string: "https://apps.apple.com/app/suhoor/id0000000000")!
            ])
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackFormView()
        }
        .alert("Mail Unavailable", isPresented: $showingMailUnavailable) {
            Button("Copy Email") {
                UIPasteboard.general.string = "chad.newbry@gmail.com"
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mail is not configured. You can email us at chad.newbry@gmail.com")
        }
    }

    private func sendSupportEmail() {
        let subject = "Suhoor Support"
        let email = "chad.newbry@gmail.com"
        let mailto = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject)"
        if let url = URL(string: mailto) {
            UIApplication.shared.open(url) { success in
                if !success {
                    showingMailUnavailable = true
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        SupportView()
    }
}
