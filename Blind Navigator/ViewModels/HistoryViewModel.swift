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

    init(storageService: StorageServiceProtocol = StorageService()) {
        print("init history model")
        self.storageService = storageService
        loadHistory()
    }

    public func loadHistory() {
        history = storageService.fetchLocalHistory()
        print(history)
        print("loading history")
    }
}
