//
//  PredictionService.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 5/29/25.
//

import CoreML

protocol PredictionServiceDelegate: AnyObject {
    func didReceivePrediction(_ prediction: String)
}

final class PredictionService {
    weak var delegate: PredictionServiceDelegate?
    var model: MLModel?
    private var predictions = [Int](repeating: 0, count: 7)
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            model = try new_sidewalk_resnet18(configuration: MLModelConfiguration()).model
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    func processSpectrogram(_ spectrogram: [[[Double]]]) {
        var classScores = [Double](repeating: 0.0, count: 7)
        for n in 0..<Constants.numSegments {
            guard let multiArray = try? MLMultiArray(
                shape: [1, 2, 64, 173],
                dataType: .float64
            ) else {
                print("Error creating MLMultiArray")
                return
            }
            fillMultiArray(multiArray, with: spectrogram[n])
            
            do {
                let input = try createFeatureProvider(with: multiArray)
                let output = try model!.prediction(from: input)
                accumulateScores(&classScores, from: output)
            } catch {
                print("Prediction error: \(error)")
                continue
            }
            let predictionString = handleFinalPrediction(classScores)
            delegate?.didReceivePrediction(predictionString)
        }
    }
    
    func fillMultiArray(_ array: MLMultiArray, with segment: [[Double]]) {
        let ptr = array.dataPointer.bindMemory(to: Double.self, capacity: array.count)
        
        for channel in 0..<2 {
            let channelOffset = channel*64*173
            for i in 0..<64 {
                for j in 0..<173 {
                    ptr[channelOffset+i*173+j] = segment[i][j]
                }
            }
        }
    }
    
    private func createFeatureProvider(with array: MLMultiArray) throws -> MLDictionaryFeatureProvider {
        let featureValue = MLFeatureValue(multiArray: array)
        return try MLDictionaryFeatureProvider(dictionary: ["x": featureValue])
    }
    
    func accumulateScores(_ scores: inout [Double], from output: MLFeatureProvider) {
        guard let outputFeature = output.featureValue(for: "linear_0") else {
            print("Missing output feature")
            return
        }
        guard let multiArray = outputFeature.multiArrayValue else {
            print("Invalid input format")
            return
        }
        guard multiArray.count == scores.count else {
            print("Dimention mismatch")
            return
        }
        for (index, value) in (0..<multiArray.count).map({ ($0, multiArray[$0].doubleValue)}) {
            scores[index]+=value
        }
    }
    
    func handleFinalPrediction(_ scores: [Double]) -> String {
        guard let maxIndex = scores.enumerated().max(by: { $0.element < $1.element })?.offset else {
            print("Failed to calculate max index of prediction array")
            return "Error"
        }
        return Constants.materials[maxIndex]
    }
}
