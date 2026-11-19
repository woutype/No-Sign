//
//  SourcesAddView.swift
//  RyukSign
//
//  Created by samara on 1.05.2025.
//

import SwiftUI
import NimbleViews
import AltSourceKit
import NimbleJSON
import OSLog
import UIKit.UIImpactFeedbackGenerator

// MARK: - View
struct SourcesAddView: View {
	@Environment(\.dismiss) var dismiss

	@State private var _filteredRecommendedSourcesData: [(url: URL, data: ASRepository)] = []
	func _refreshFilteredRecommendedSourcesData() {
		let filtered = recommendedSourcesData
			.filter { (url, data) in
				let id = data.id ?? url.absoluteString
				return !Storage.shared.sourceExists(id)
			}
			.sorted { lhs, rhs in
				let lhsName = lhs.data.name ?? ""
				let rhsName = rhs.data.name ?? ""
				return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending
			}
		_filteredRecommendedSourcesData = filtered
	}

	@State var recommendedSourcesData: [(url: URL, data: ASRepository)] = []
	let recommendedSources: [URL] = [
		"https://raw.githubusercontent.com/faroukbmiled/RyukSign/refs/heads/main/app-repo.json",
		"https://raw.githubusercontent.com/claration/Feather/refs/heads/main/app-repo.json",
		"https://raw.githubusercontent.com/Aidoku/Aidoku/altstore/apps.json",
		"https://github.com/chachillie/Flycast-iOS/raw/main/flycast-ios.json",
		"https://xitrix.github.io/iTorrent/AltStore.json",
		"https://altstore.oatmealdome.me/",
		"https://raw.githubusercontent.com/LiveContainer/LiveContainer/refs/heads/main/apps.json",
		"https://pokemmo.com/altstore",
		"https://provenance-emu.com/apps.json",
		"https://community-apps.sidestore.io/sidecommunity.json",
		"https://alt.getutm.app",
		"https://raw.githubusercontent.com/paigely/Navic/refs/heads/master/app-repo.json",
		"https://stikdebug.xyz/index.json",
		"https://apps.manicemu.site/altstore",
		"https://alt.crystall1ne.dev"
	].map { URL(string: $0)! }

	// MARK: - Ryuk Repos Collection
	@State var ryukRepos: [URL] = []
	@State var ryukReposCount: Int = 0
	@State var ryukReposFetchError: String? = nil

	@State private var _isImporting = false
	@State var _isAddingRyukRepos = false
	@State private var _isSavingSource = false
	@State private var _sourceURL = ""
	@State private var _showRyukErrorAlert = false

	// MARK: Body
	var body: some View {
		NBNavigationView(.localized("Add Source"), displayMode: .inline) {
			formContent
				.toolbar { toolbarContent }
				.animation(.default, value: _filteredRecommendedSourcesData.map { $0.data.id ?? "" })
				.alert("Failed to Load Ryuk Repos", isPresented: $_showRyukErrorAlert) {
					Button("OK", role: .cancel) { }
					Button("Retry") {
						Task {
							await _fetchRyukReposList()
						}
					}
				} message: {
					Text(ryukReposFetchError ?? "An unknown error occurred")
				}
				.task {
					await _fetchRecommendedRepositories()
					await _fetchRyukReposList()
				}
		}
	}

	@AppStorage("Feather.sourcesTabShowAllReposDirectly")
	var _sourcesTabShowAllReposDirectly: Bool = false

	@ViewBuilder
	var formContent: some View {
		Form {
			sourceURLSection
			importExportSection
			ryukReposSection
			displaySection
			featuredSection
		}
		.dismissableKeyboard()
	}

	@ViewBuilder
	var sourceURLSection: some View {
		NBSection(.localized("Source URL")) {
			TextField(.localized("Enter Source URL"), text: $_sourceURL)
				.keyboardType(.URL)
				.textInputAutocapitalization(.never)
		} footer: {
			Text(.localized("The only supported repositories are AltStore repositories."))
			Text(verbatim: "[\(String.localized("Learn more about how to setup a repository..."))](https://faq.altstore.io/developers/make-a-source)")
		}
	}

	@ViewBuilder
	var importExportSection: some View {
		Section {
			Button(.localized("Import"), systemImage: "square.and.arrow.down") {
				_isImporting = true
				_fetchImportedRepositories(UIPasteboard.general.string) { success, count in
					_isImporting = false
					if success {
						Toast.success("Successfully imported \(count) source\(count == 1 ? "" : "s")")
					} else {
						Toast.error("No valid sources found in clipboard", duration: .sticky)
					}
				}
			}

			Button(.localized("Export"), systemImage: "doc.on.doc") {
				let sources = Storage.shared.getSources()
				if sources.isEmpty {
					Toast.error("No sources to export", duration: .sticky)
				} else {
					UIPasteboard.general.string = sources.map {
						$0.sourceURL!.absoluteString
					}.joined(separator: "\n")
					Toast.success("Successfully exported \(sources.count) source\(sources.count == 1 ? "" : "s") to clipboard")
				}
			}
		} footer: {
			Text(.localized("Supports importing from KravaSign/MapleSign and ESign."))
		}
	}

	@ViewBuilder
	var ryukReposSection: some View {
		Section {
			Button(action: {
				if ryukRepos.isEmpty {
					Task {
						await _fetchRyukReposList()
						if !ryukRepos.isEmpty {
							_isAddingRyukRepos = true
							_addRyukRepos()
						}
					}
				} else {
					_isAddingRyukRepos = true
					_addRyukRepos()
				}
			}) {
				HStack {
					Image(systemName: "bolt.fill")
						.foregroundColor(.orange)
					VStack(alignment: .leading, spacing: 2) {
						Text("Ryuk Repos")
							.font(.headline)
							.foregroundColor(.primary)
						if ryukReposCount > 0 {
							Text("Add \(ryukReposCount) Ryuk crafted repositories")
								.font(.caption)
								.foregroundColor(.secondary)
						} else if ryukReposFetchError != nil {
							Text("Tap to retry loading repositories")
								.font(.caption)
								.foregroundColor(.red)
						} else {
							Text("Loading repositories...")
								.font(.caption)
								.foregroundColor(.secondary)
						}
					}
					Spacer()
					if _isAddingRyukRepos || (ryukReposCount == 0 && ryukReposFetchError == nil) {
						ProgressView()
							.scaleEffect(0.8)
					} else if ryukReposFetchError != nil {
						Image(systemName: "exclamationmark.triangle")
							.foregroundColor(.red)
							.font(.caption)
					} else {
						Image(systemName: "chevron.right")
							.foregroundColor(.secondary)
							.font(.caption)
					}
				}
				.contentShape(Rectangle())
			}
			.buttonStyle(PlainButtonStyle())
			.disabled(_isAddingRyukRepos || (ryukReposCount == 0 && ryukReposFetchError == nil))
		} footer: {
			if let error = ryukReposFetchError {
				Text(error)
					.foregroundColor(.red)
			} else {
				Text("Add a collection of popular repositories crafted by Ryuk.")
			}
		}
	}

	@ViewBuilder
	var displaySection: some View {
		Section {
			Toggle(isOn: $_sourcesTabShowAllReposDirectly) {
				Label(.localized("Show All Repos by Default"), systemImage: "square.stack")
			}
		} footer: {
			Text(.localized("When enabled, the Sources tab shows all apps directly. Toggle off to manage sources."))
		}
	}

	@ViewBuilder
	var featuredSection: some View {
		if !_filteredRecommendedSourcesData.isEmpty {
			NBSection(.localized("Featured")) {
				ForEach(_filteredRecommendedSourcesData, id: \.url) { (url, source) in
					HStack(spacing: 2) {
						FRIconCellView(
							title: source.name ?? .localized("Unknown"),
							subtitle: url.absoluteString,
							iconUrl: source.currentIconURL
						)
						Button {
							Storage.shared.addSource(url, repository: source) { error in
								_refreshFilteredRecommendedSourcesData()
								if let error = error {
									Toast.error(error.localizedDescription, duration: .sticky)
								} else {
									let sourceName = source.name ?? "Repository"
									Toast.success("Successfully added \(sourceName)")
								}
							}
						} label: {
							NBButton(.localized("Add"), systemImage: "arrow.down", style: .text)
						}
					}
				}
			}
		}
	}

	@ToolbarContentBuilder
	var toolbarContent: some ToolbarContent {
		NBToolbarButton(role: .cancel)

		if !_isImporting && !_isAddingRyukRepos && !_isSavingSource {
			NBToolbarButton(
				.localized("Save"),
				style: .text,
				placement: .confirmationAction
			) {
				if _sourceURL.isEmpty {
					dismiss()
					return
				}

				_isSavingSource = true
				FR.handleSource(_sourceURL, showAlerts: false) { result in
					_isSavingSource = false
					switch result {
					case .success(let sourceName):
						Toast.success("Successfully added \(sourceName)")
						dismiss()
					case .failure(let error):
						Toast.error(error.localizedDescription, duration: .sticky)
					}
				}
			}
		} else {
			ToolbarItem(placement: .confirmationAction) {
				ProgressView()
			}
		}
	}

}
