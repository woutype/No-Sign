//
//  SettingsView.swift
//  RyukSign
//
//  Created by samara on 10.04.2025.
//

import SwiftUI
import NimbleViews
import UIKit
import Darwin
import IDeviceSwift

// MARK: - View
struct SettingsView: View {
    @AppStorage("feather.selectedCert") private var _storedSelectedCert: Int = 0
    @State private var _currentIcon: String? = UIApplication.shared.alternateIconName
    @ObservedObject private var _selfUpdate = SelfUpdateManager.shared

    // MARK: Fetch
    @FetchRequest(
        entity: CertificatePair.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CertificatePair.date, ascending: false)],
        animation: .snappy
    ) private var _certificates: FetchedResults<CertificatePair>

    private var selectedCertificate: CertificatePair? {
        guard
            _storedSelectedCert >= 0,
            _storedSelectedCert < _certificates.count
        else {
            return nil
        }
        return _certificates[_storedSelectedCert]
    }

    // MARK: Body
    var body: some View {
        NBNavigationView(.localized("Settings")) {
            Form {
                _feedback()
                
                Section {
                    NavigationLink(destination: AppearanceView()) {
                        Label(.localized("Appearance"), systemImage: "paintbrush")
                    }
					NavigationLink(destination: AppIconView(currentIcon: $_currentIcon)) {
						Label(.localized("App Icon"), systemImage: "app.badge")
					}
					NavigationLink(destination: TabBarSettingsView()) {
						Label(.localized("Tab Bar"), systemImage: "squares.below.rectangle")
					}
					NavigationLink(destination: SourcesSettingsView()) {
						Label(.localized("Sources"), systemImage: "globe.desk")
					}
					NavigationLink(destination: DownloadsSettingsView()) {
						Label(.localized("Downloads"), systemImage: "arrow.down.circle")
					}
					NavigationLink(destination: UpdatesSettingsView()) {
						HStack {
							Label(.localized("Updates"), systemImage: "arrow.triangle.2.circlepath")
							if _selfUpdate.available != nil {
								Spacer()
								Circle().fill(Color.accentColor).frame(width: 8, height: 8)
							}
						}
					}
                }
                
                NBSection(.localized("Certificates")) {
                    if let cert = selectedCertificate {
                        CertificatesCellView(cert: cert)
                    } else {
                        Text(.localized("No Certificate"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    NavigationLink(destination: CertificatesView()) {
                        Label(.localized("Certificates"), systemImage: "checkmark.seal")
                    }
                } footer: {
                    Text(.localized("Add and manage certificates used for signing applications."))
                }

                NBSection(.localized("Signing")) {
                    NavigationLink(destination: ConfigurationView()) {
                        Label(.localized("Signing Options"), systemImage: "signature")
                    }
                    NavigationLink {
                        TweakLibraryList().navigationTitle(.localized("Tweaks"))
                    } label: {
                        Label(.localized("Tweaks"), systemImage: "wrench.and.screwdriver")
                    }
                    NavigationLink(destination: InstallationView()) {
                        Label(.localized("Installation"), systemImage: "arrow.down.app")
                    }
                }

                _files()

                Section {
                    NavigationLink(destination: StorageView()) {
                        Label(.localized("Storage"), systemImage: "internaldrive")
                    }
                    NavigationLink(destination: LogsHistoryView()) {
                        Label(.localized("Activity Logs"), systemImage: "text.alignleft")
                    }
                    NavigationLink(destination: BackupView()) {
                        Label(.localized("Backup & Restore"), systemImage: "clock.arrow.circlepath")
                    }
                    NavigationLink(destination: ResetView()) {
                        Label(.localized("Reset"), systemImage: "trash")
                    }
                } footer: {
                    Text(.localized("Check what is using space, back up your setup, or reset the app."))
                }
            }
        }
    }
}

// MARK: - View extension
extension SettingsView {
    @ViewBuilder
    private func _feedback() -> some View {
        Section {
            NavigationLink(destination: AboutView()) {
                Label {
                    Text(verbatim: .localized("About %@", arguments: Bundle.main.name))
                } icon: {
					FRAppIconView(size: 23)
                }
            }
        }
    }
    
    @ViewBuilder
    private func _files() -> some View {
        NBSection(.localized("Files")) {
            NavigationLink(destination: FilesCompressionView()) {
                Label(.localized("Files & Compression"), systemImage: "archivebox")
            }
            NavigationLink(destination: WebManagerView()) {
                Label(.localized("Web Manager"), systemImage: "externaldrive.badge.wifi")
            }
            Menu {
                Button(.localized("Open Documents"), systemImage: "folder") {
                    UIApplication.open(URL.documentsDirectory.toSharedDocumentsURL()!)
                }
                Button(.localized("Open Archives"), systemImage: "archivebox") {
                    UIApplication.open(FileManager.default.archives.toSharedDocumentsURL()!)
                }
                Button(.localized("Open Certificates"), systemImage: "checkmark.seal") {
                    UIApplication.open(FileManager.default.certificates.toSharedDocumentsURL()!)
                }
            } label: {
                Label(.localized("Open in Files"), systemImage: "folder")
            }
        }
    }
}
