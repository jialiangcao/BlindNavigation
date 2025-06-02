//
//  StopwatchView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/2/25.
//

import SwiftUI

struct StopwatchView: View {
    @State private var elapsedSeconds = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        HStack {
            Image(systemName: "timer")
                .font(.title2)
                .foregroundColor(.blue)
            Text(timeString(from: elapsedSeconds))
                .font(.system(.title2))
                .onReceive(timer) { _ in
                    elapsedSeconds += 1
                }
        }
        .font(.system(.title2))
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 2)
        )
        .padding(8)
    }
    
    func timeString(from seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}

#Preview {
    StopwatchView()
}
