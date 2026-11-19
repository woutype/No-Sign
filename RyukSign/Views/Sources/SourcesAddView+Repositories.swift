//
//  SourcesAddView+Repositories.swift
//  RyukSign
//

import SwiftUI
import NimbleViews
import AltSourceKit
import OSLog
import UIKit.UIImpactFeedbackGenerator

extension SourcesAddView {
	// MARK: - Fetch Ryuk Repos List
	func _fetchRyukReposList() async {
		await MainActor.run {
			ryukReposFetchError = nil
		}

		do {
			let (data, response) = try await URLSession.shared.data(from: RyukSignAPI.reposListURL)

			guard let httpResponse = response as? HTTPURLResponse,
				httpResponse.statusCode == 200 else {
				await MainActor.run {
					ryukReposFetchError = "Failed to fetch repository list. Server returned an error."
					Logger.misc.error("Failed to fetch Ryuk repos: Invalid response")
				}
				return
			}

			let raw = try JSONSerialization.jsonObject(with: data, options: [])

			guard let strings = raw as? [String] else {
				await MainActor.run {
					ryukReposFetchError = "Unexpected JSON format in repos.json"
				}
				return
			}

			let urls = strings.compactMap { URL(string: $0) }

			await MainActor.run {
				ryukRepos = urls
				ryukReposCount = urls.count
				ryukReposFetchError = nil
				Logger.misc.info("Successfully fetched \(urls.count) Ryuk repos")
			}

		} catch {
			await MainActor.run {
				if (error as NSError).code == NSURLErrorNotConnectedToInternet ||
					(error as NSError).code == NSURLErrorTimedOut ||
					(error as NSError).code == NSURLErrorNetworkConnectionLost {
					ryukReposFetchError = "No internet connection. Please check your network and try again."
				} else {
					ryukReposFetchError = "Failed to load repositories: \(error.localizedDescription)"
				}
				ryukReposCount = 0
				Logger.misc.error("Failed to fetch Ryuk repos: \(error.localizedDescription)")
			}
		}
	}

	// MARK: - Ryuk Repos Handler
	func _addRyukRepos() {
		guard !ryukRepos.isEmpty else {
			_isAddingRyukRepos = false
			Toast.error("No Ryuk repositories available", duration: .sticky)
			return
		}

		Task {
			let fetched = await FR.fetchRepositories(from: ryukRepos)
			let dict = Dictionary(fetched, uniquingKeysWith: { first, _ in first })

			await MainActor.run {
				if dict.isEmpty {
					_isAddingRyukRepos = false
					Toast.error("Failed to fetch repository data. Please check your connection and try again.", duration: .sticky)
				} else {
					Storage.shared.addSources(repos: dict) { _ in
						Toast.success("Successfully added \(dict.count) Ryuk repositories")
						_isAddingRyukRepos = false
						_refreshFilteredRecommendedSourcesData()
						dismiss()
					}
				}
			}
		}
	}

	func _fetchRecommendedRepositories() async {
		let fetched = await FR.fetchRepositories(from: recommendedSources)
		await MainActor.run {
			recommendedSourcesData = fetched
			_refreshFilteredRecommendedSourcesData()
		}
	}

	func _fetchImportedRepositories(
		_ code: String?,
		competion: @escaping (Bool, Int) -> Void
	) {
		guard let code else {
			competion(false, 0)
			return
		}

		let handler = ASDeobfuscator(with: code)
		let repoUrls = handler.decode().compactMap { URL(string: $0) }
		guard !repoUrls.isEmpty else {
			competion(false, 0)
			return
		}

		Task {
			let fetched = await FR.fetchRepositories(from: repoUrls)

			let dict = Dictionary(fetched, uniquingKeysWith: { first, _ in first })

			await MainActor.run {
				if dict.isEmpty {
					competion(false, 0)
				} else {
					Storage.shared.addSources(repos: dict) { _ in
						competion(true, dict.count)
					}
				}
			}
		}
	}
}
