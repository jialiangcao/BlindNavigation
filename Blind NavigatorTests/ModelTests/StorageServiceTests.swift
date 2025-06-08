//
//  StorageServiceTests.swift
//  Blind NavigatorTests
//
//  Created by Jialiang Cao on 6/7/25.
//

@testable import Blind_Navigator

import XCTest

class StorageServiceTests: XCTestCase {
    var storageService: StorageService!
    let testSessionId = "testSession"
    let headers = "timestamp,latitude,longitude\n"
    var testFileURL: URL!
    
    override func setUpWithError() throws {
        storageService = StorageService()
        testFileURL = try storageService.createCSVFile(sessionId: testSessionId, headers: headers)
    }
    
    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: testFileURL.path) {
            try FileManager.default.removeItem(at: testFileURL)
        }
        UserDefaults.standard.removeObject(forKey: "sessionFileHistory")
        storageService.closeFile()
        storageService = nil
    }
    
    func testCreateCSVFile() throws {
        XCTAssertTrue(FileManager.default.fileExists(atPath: testFileURL.path))
        let contents = try String(contentsOf: testFileURL, encoding: .utf8)
        XCTAssertEqual(contents, headers)
    }
    
    func testAppendRow() throws {
        let row = "2025-06-08 00:00:00,40.0,-73\n"
        try storageService.append(row: row, to: testFileURL)
        storageService.closeFile()
        
        let contents = try String(contentsOf: testFileURL, encoding: .utf8)
        XCTAssertTrue(contents.contains(row))
    }
    
    func testCloseFileDoesNotThrow() {
        XCTAssertNoThrow(storageService.closeFile())
    }
    
    func testSaveFileOnDevice() throws {
        storageService.saveFileOnDevice(originalURL: testFileURL)
        let savedPaths = UserDefaults.standard.stringArray(forKey: "sessionFileHistory")
        XCTAssertNotNil(savedPaths)
        XCTAssertTrue(savedPaths!.contains(where: { $0.contains(testSessionId) }))
    }
    
    func testFetchLocalHistory() throws {
        storageService.saveFileOnDevice(originalURL: testFileURL)
        let history = storageService.fetchLocalHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertTrue(history[0].lastPathComponent.contains(testSessionId))
    }
    
    func testDeleteFile() throws {
        storageService.saveFileOnDevice(originalURL: testFileURL)
        storageService.deleteFile(localFileURL: testFileURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: testFileURL.path))
        
        let savedPaths = UserDefaults.standard.stringArray(forKey: "sessionFileHistory")
        XCTAssertFalse(savedPaths!.contains(testFileURL.path))
    }
    
    //func testUploadFile() throws {
    //}
}
