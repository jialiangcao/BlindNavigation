//
//  StorageService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import Foundation
import FirebaseStorage

protocol StorageServiceType {
    func createCSVFile(sessionId: String, headers: String) throws -> URL
    func append(row: String, to fileURL: URL) throws
    func closeFile()
    func uploadFile(localFileURL: URL, remotePath: String, completion: @escaping (Result<URL, Error>) -> Void)
    func saveFileOnDevice(originalURL: URL)
    func fetchLocalHistory() -> [URL]
    func deleteFile(localFileURL: URL)
}

final class StorageService: StorageServiceType {
    private var fileHandle: FileHandle?
    private let historyKey = "sessionFileHistory"
    
    func createCSVFile(sessionId: String, headers: String) throws -> URL {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documents.appendingPathComponent("data-"+"\(sessionId).csv")
        
        if !fileManager.fileExists(atPath: fileURL.path) {
            try headers.write(to: fileURL, atomically: true, encoding: .utf8)
        }
        
        fileHandle = try FileHandle(forWritingTo: fileURL)
        fileHandle?.seekToEndOfFile()
        return fileURL
    }
    
    func append(row: String, to fileURL: URL) throws {
        guard let data = row.data(using: .utf8) else { return }
        if fileHandle == nil {
            fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle?.seekToEndOfFile()
        }
        fileHandle?.write(data)
    }
    
    func closeFile() {
        fileHandle?.closeFile()
        fileHandle = nil
    }
    
    func uploadFile(localFileURL: URL, remotePath: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference(withPath: remotePath)
        storageRef.putFile(from: localFileURL, metadata: nil) { metadata, error in
            if let error = error {
                print(error)
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let downloadURL = url {
                    completion(.success(downloadURL))
                }
            }
        }
    }
    
    func saveFileOnDevice(originalURL: URL) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(originalURL.lastPathComponent)
        do {
            if !fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.copyItem(at: originalURL, to: destinationURL)
            }
            saveToDefaults(fileURL: destinationURL)
        } catch {
            print("Failed to copy file: \(error)")
        }
    }
    
    func saveToDefaults(fileURL: URL) {
        var savedPaths = UserDefaults.standard.stringArray(forKey: historyKey) ?? []
        savedPaths.append(fileURL.path)
        UserDefaults.standard.set(savedPaths, forKey: historyKey)
    }

    func fetchLocalHistory() -> [URL] {
        let savedPaths = UserDefaults.standard.stringArray(forKey: historyKey) ?? []
        return savedPaths.compactMap { URL(fileURLWithPath: $0) }
    }
    
    func deleteFile(localFileURL: URL) {
        let fileManager = FileManager.default
        
        do {
            if fileManager.fileExists(atPath: localFileURL.path) {
                try fileManager.removeItem(at: localFileURL)
            } else {
                print("File does not exist")
            }
        } catch {
            print("File delete failed, error: \(error)")
        }
        
        var savedPaths = UserDefaults.standard.stringArray(forKey: historyKey) ?? []
        savedPaths.removeAll { $0 == localFileURL.path }
        UserDefaults.standard.set(savedPaths, forKey: historyKey)
    }
}
