//
//  AboutView.swift
//  RyukSign
//
//  Created by samara on 30.04.2025.
//

import SwiftUI
import NimbleViews

// MARK: - View
struct AboutView: View {
	// MARK: Body
	var body: some View {
		NBList(.localized("About")) {
			Section {
				VStack(spacing: 8) {
					FRAppIconView(size: 72)

					Text("No-Sign")
						.font(.largeTitle)
						.bold()
						.foregroundStyle(Color.accentColor)

					HStack(spacing: 4) {
						Text(.localized("Version"))
						Text(Bundle.main.version)
					}
					.font(.footnote)
					.foregroundStyle(.secondary)

					Text("woutype")
						.font(.footnote)
						.foregroundStyle(.secondary)
				}
			}
			.frame(maxWidth: .infinity)
			.listRowBackground(EmptyView())
		}
	}
}
