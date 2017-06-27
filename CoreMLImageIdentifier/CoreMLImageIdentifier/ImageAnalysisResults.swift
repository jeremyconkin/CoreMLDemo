//
//  ImageAnalysisResults.swift
//  CoreMLImageIdentifier
//
//  Created by Jeremy Conkin on 6/26/17.
//  Copyright © 2017 JeremyConkin. All rights reserved.
//

import CoreVideo

/// Object type and confidence from a machine learning analysis
struct ImageAnalysisResults {

    /// What the model predicted it saw
    let analysisObjectType: String

    /// How confident (0-1) the model was in its prediction
    let confidence: Double

    /// Given a pixel buffer, perform a model analysis on it and put the results in
    /// a return object
    ///
    /// - Parameter pixelBuffer: Pixel buffer to be analyzed
    /// - Returns: Analysis results
    static func createFromPixelBuffer(_ pixelBuffer: CVPixelBuffer) -> ImageAnalysisResults? {

        do {

            let resnetModel = Resnet50()

            // Get the model's prediction
            let output = try resnetModel.prediction(image: pixelBuffer)

            // Sort results
            let sorted = output.classLabelProbs.sorted(by: { (lhs, rhs) -> Bool in

                return lhs.value > rhs.value
            })

            return ImageAnalysisResults(analysisObjectType: sorted[0].key, confidence: sorted[0].value)

        } catch {

            print(error)
        }

        return nil
    }
}
