//
//  FeedbackButton.swift
//  Mathulator
//
//  Created by Joachim Seland Graff on 2026-10-24.
//


import SwiftUI
import UIKit

struct FeedbackButton: View {
    let appName: String
    let feedbackEmail: String
    var onFallback: (() -> Void)? = nil

    @State private var showFallback = false
    @State private var copied = false

    var body: some View {
        Button {
            sendFeedback()
        } label: {
            Label("Send feedback", systemImage: "envelope")
        }
        .alert("Unable to Open Email", isPresented: $showFallback) {
            Button("Copy Email Address") {
                UIPasteboard.general.string = feedbackEmail
                copied = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                """
                Please send your feedback to:

                \(feedbackEmail)

                You can write the email manually.
                """
            )
        }
        .alert("Email address copied", isPresented: $copied) {
            Button("OK", role: .cancel) {}
        }
    }

    private func sendFeedback() {
        let version = Bundle.main.infoDictionary?[
            "CFBundleShortVersionString"
        ] as? String ?? "Unknown"

        let subject = "\(appName) feedback"
        let body = """
        App version: \(version)

        Feedback:

        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]

        guard let url = components.url else {
            if let onFallback = self.onFallback {
                onFallback()
            } else {
                self.showFallback = true
            }
            return
        }

        UIApplication.shared.open(url) { success in
            if !success {
                DispatchQueue.main.async {
                    if let onFallback = self.onFallback {
                        onFallback()
                    } else {
                        self.showFallback = true
                    }
                }
            }
        }
    }
}

