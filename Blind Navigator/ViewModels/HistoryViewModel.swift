//
//  HistoryViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import Foundation

final class HistoryViewModel: ObservableObject {
    @Published var history: [URL] = []
    @Published var selectedFiles: Set<URL> = []
    @Published var uploadStatus: Bool?
    
    private let storageService: StorageServiceType
    private let authViewModel: AuthViewModelType

    init(storageService: StorageServiceType = StorageService(), authViewModel: AuthViewModelType = AuthViewModel()) {
        self.storageService = storageService
        self.authViewModel = authViewModel
        loadHistory()
    }

    public func loadHistory() {
        history = storageService.fetchLocalHistory()
    }
    
    public func deleteSelectedFiles() {
        for url in selectedFiles {
            storageService.deleteFile(localFileURL: url)
        }
        selectedFiles = []
        loadHistory()
    }
    
    public func uploadSelectedFiles() {
        guard let email = authViewModel.getUserEmail() else {
            print("No email")
            uploadStatus = false
            return
        }
        
        guard !selectedFiles.isEmpty else {
            print("No files selected")
            uploadStatus = false
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var uploadFailed = false

        for url in selectedFiles {
            dispatchGroup.enter()
            print(url)
            let remotePath: String
            if (url.pathExtension == "mov") {
                remotePath = "BlindNavigator/\(email)/sessions/video/\(url.lastPathComponent)"
            } else if (url.pathExtension == "m4a") {
                remotePath = "BlindNavigator/\(email)/sessions/audio/\(url.lastPathComponent)"
            } else if (url.pathExtension == "csv") {
                remotePath = "BlindNavigator/\(email)/sessions/csv/\(url.lastPathComponent)"
            } else {
                remotePath = "BlindNavigator/\(email)/sessions/other/\(url.lastPathComponent)"
            }

            storageService.uploadFile(localFileURL: url, remotePath: remotePath) { result in
                switch result {
                case .failure(_):
                    uploadFailed = true
                case .success(let result):
                    print(result)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.deleteSelectedFiles()
            if uploadFailed {
                self.uploadStatus = false
            } else {
                self.uploadStatus = true
            }
        }
    }
}
