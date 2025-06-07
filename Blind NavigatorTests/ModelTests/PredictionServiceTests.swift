//
//  PredictionServiceTests.swift
//  Blind NavigatorTests
//
//  Created by Jialiang Cao on 6/7/25.
//

@testable import Blind_Navigator

import XCTest
import CoreML

private class MockModel: MLModel {
    override func prediction(from input: MLFeatureProvider) throws -> MLFeatureProvider {
        let arr = try MLMultiArray(shape: [7], dataType: .double)
        for i in 0..<7 {
            arr[i] = NSNumber(value: i)
        }
        let fv = MLFeatureValue(multiArray: arr)
        return try MLDictionaryFeatureProvider(dictionary: ["linear_0": fv])
    }
}

final class PredictionServiceTests: XCTestCase {
    private class MockDelegate: PredictionServiceDelegate {
        var received: [String] = []
        func didReceivePrediction(_ prediction: String) {
            received.append(prediction)
        }
    }
    
    func testHandleFinalPrediction() {
        let scores = [0.0, 10.0, 5.0] + [Double](repeating: 0, count: Constants.materials.count - 3)
        let predictionService = PredictionService()
        let picked = predictionService.handleFinalPrediction(scores)
        // Test should return index 1, concrete
        XCTAssertEqual(picked, Constants.materials[1])
    }
    
    func testAccumulateScores() throws {
        let arr = try MLMultiArray(shape: [7], dataType: .double)
        for i in 0..<7 { arr[i] = NSNumber(value: i + 1) }
        let provider = try MLDictionaryFeatureProvider(dictionary: ["linear_0": MLFeatureValue(multiArray: arr)])
        
        var scores = [Double](repeating: 0.0, count: 7)
        let predictionService = PredictionService()
        predictionService.accumulateScores(&scores, from: provider)
        
        XCTAssertEqual(scores, [1,2,3,4,5,6,7])
    }
    
    func testFillMultiArray() throws {
        let segment = Array(
            repeating: Array(repeating: 42.0, count: 173),
            count: 64
        )
        let array = try MLMultiArray(shape: [1, 2, 64, 173], dataType: .double)
        let predictionService = PredictionService()
        predictionService.fillMultiArray(array, with: segment)
        
        let ptr = array.dataPointer.bindMemory(to: Double.self, capacity: array.count)
        XCTAssertEqual(ptr[0], 42.0)
        let offset = 64 * 173
        let idx = offset + 63 * 173 + 172
        XCTAssertEqual(ptr[idx], 42.0)
    }
    
    func testProcessSpectrogram() {
        let numSegments = Constants.numSegments
        let dummySegment = Array(
            repeating: Array(repeating: 0.0, count: 173),
            count: 64
        )
        let spectrogram = Array(repeating: dummySegment, count: numSegments)
        
        let predictionService = PredictionService()
        predictionService.model = MockModel()
        let delegate = MockDelegate()
        predictionService.delegate = delegate
        
        predictionService.processSpectrogram(spectrogram)
        
        XCTAssertEqual(delegate.received.count, numSegments)
        for prediction in delegate.received {
            XCTAssertEqual(prediction, Constants.materials[6])
        }
    }
}

