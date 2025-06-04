//
//  HistoryViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var history: [URL] = []
    @Published var selectedFiles: Set<URL> = []
    @Published var uploadStatus: Bool?
    
    private let storageService: StorageServiceProtocol
    private let authVM: AuthViewModel

    init() {
        self.storageService = StorageService()
        self.authVM = AuthViewModel()
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
        guard let email = authVM.getUserEmail() else {
            print("No email")
            return
        }
        
        guard !selectedFiles.isEmpty else {
            print("No files selected")
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var uploadFailed = false

        for url in selectedFiles {
            dispatchGroup.enter()
            let remotePath = "BlindNavigator/\(email)/sessions/\(url.lastPathComponent)"
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
