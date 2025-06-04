//
//  HistoryViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var history: [URL] = []
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
    
    public func delete() {
        storageService.clearData()
        loadHistory()
    }
    
    public func upload() {
        guard let email = authVM.getUserEmail() else {
            print("No email")
            return
        }

        for url in history {
            let remotePath = "BlindNavigator/\(email)/sessions/\(url.lastPathComponent)"
            storageService.uploadFile(localFileURL: url, remotePath: remotePath) { result in
                print(result)
            }
        }
    }
}
