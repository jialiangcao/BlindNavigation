//
//  HistoryView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    
    var body: some View {
        VStack {
            Text("History")
                .font(.headline)
                .padding(.top)
            
            List(historyViewModel.history, id: \.self) { fileURL in
                Text(fileURL.lastPathComponent)
            }
        }
    }
}

#Preview {
    HistoryView(historyViewModel: HistoryViewModel())
}
