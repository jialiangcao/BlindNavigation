//
//  HistoryView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    
    func viewHistory() {
        historyViewModel.loadHistory()
    }
    
    var body: some View {
        VStack {
            Button(action: viewHistory) {
                Text("View History")
            }
            
            List(historyViewModel.history, id: \.self) { fileURL in
                Text(fileURL.lastPathComponent)
            }
        }
    }
}

#Preview {
    HistoryView(historyViewModel: HistoryViewModel())
}
