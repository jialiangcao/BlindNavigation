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
}

class StorageService: StorageServiceProtocol {
    private var fileHandle: FileHandle?
    
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
        let uploadTask = storageRef.putFile(from: localFileURL, metadata: nil) { metadata, error in
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
        
        uploadTask.observe(.progress) { snapshot in
            // Currently unused
            let percent = 100.0 * Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
        }
    }
}
