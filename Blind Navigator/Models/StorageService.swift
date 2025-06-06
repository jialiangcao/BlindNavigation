//
//  StorageService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 6/3/25.
//

import Foundation
import FirebaseStorage

protocol StorageServiceProtocol {
    func createCSVFile(sessionId: String, headers: String) throws -> URL
    func append(row: String, to fileURL: URL) throws
    func closeFile()
    func uploadFile(localFileURL: URL, remotePath: String, completion: @escaping (Result<URL, Error>) -> Void)
    func saveFileOnDevice(originalURL: URL)
    func fetchLocalHistory() -> [URL]
    func deleteFile(localFileURL: URL)
}

class StorageService: StorageServiceProtocol {
    private var fileHandle: FileHandle?
    private let historyKey = "sessionFileHistory"
    
    func createCSVFile(sessionId: String, headers: String) throws -> URL {
        let fileManager = FileManager.default
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documents.appendingPathComponent("\(sessionId).csv")
        
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
        var data: Data?
        do {
            data = try Data(contentsOf: localFileURL)
        } catch let error {
            print("Error creating data from file URL")
            completion(.failure(error))
            return
        }
        
        // Need to define metadata manually as data is automatically recognized as "application/octet-stream"
        var fileMetadata: StorageMetadata? = nil
        if (localFileURL.pathExtension == "m4a") {
            let metadata = StorageMetadata()
            metadata.contentType = "audio/m4a"
            fileMetadata = metadata
        } else if (localFileURL.pathExtension == "csv") {
            let metadata = StorageMetadata()
            metadata.contentType = "text/csv"
            fileMetadata = metadata
        }
        
        // Needs to use putData instead of putFile to avoid iOS reusing the same upload task
        storageRef.putData(data!, metadata: fileMetadata) { metadata, error in
            if let error = error {
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
    
    private func saveToDefaults(fileURL: URL) {
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
