//
//  HistoryView.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyViewModel: HistoryViewModel
    @State private var selectedFiles: Set<URL> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if historyViewModel.history.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No history yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Your history will be available here after you complete a session.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    List(selection: $selectedFiles) {
                        ForEach(historyViewModel.history, id: \.self) { fileURL in
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fileURL.lastPathComponent)
                                        .font(.headline)
                                    Text(fileURL.deletingPathExtension().lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .environment(\.editMode, .constant(.active))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                if selectedFiles.count == historyViewModel.history.count {
                                    selectedFiles.removeAll()
                                } else {
                                    selectedFiles = Set(historyViewModel.history)
                                }
                            }) {
                                Text(selectedFiles.count == historyViewModel.history.count ? "Deselect All" : "Select All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Divider()
                
                HStack(spacing: 12) {
                    Button(role: .destructive, action: {
                        // Delete selected action
                    }) {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(selectedFiles.isEmpty)
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        // Upload selected action
                    }) {
                        Label("Upload", systemImage: "arrow.up.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(selectedFiles.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -1)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let dummyHistoryViewModel = HistoryViewModel()
    dummyHistoryViewModel.history = [
        URL(string: "file:///Users/test/Documents/2024-05-12-05:02:11.csv")!,
        URL(string: "file:///Users/test/Documents/audio2.wav")!,
        URL(string: "file:///Users/test/Documents/audio3.wav")!
    ]
    
    return HistoryView(historyViewModel: dummyHistoryViewModel)
}
