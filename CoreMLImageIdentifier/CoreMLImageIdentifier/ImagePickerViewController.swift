//
//  ImagePickerViewController.swift
//  CoreMLImageIdentifier
//
//  Created by Jeremy Conkin on 6/26/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

/// Select an image and have coreML analysis performed on it
class ImagePickerViewController : UIViewController, UINavigationControllerDelegate {

    /// Image that the user selected for analysis
    @IBOutlet weak var imageView: UIImageView!

    /// Label saying what the machine learning model thinks is in the image
    @IBOutlet weak var whatIsThisLabel: UILabel!

    /// Label describing the model's confidence
    @IBOutlet weak var confidenceLabel: UILabel!

    /// Image picker to present by a user action
    private let picker = UIImagePickerController()

    override func viewDidLoad() {

        super.viewDidLoad()
        picker.delegate = self
    }

    /// User requested to pick a photo from a phot picker
    ///
    /// - Parameter sender: Button tapped to form the request
    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {

        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }

    /// Analyze an image and show the results in the UI
    ///
    /// - Parameter imageForAnalysis: Image for the CoreML model to analyze
    func analyzeImage(_ inputImage: UIImage) {

        // The input image size should be 224x224 for ResNet
        guard let resizedImage = inputImage.resize(size: CGSize(width: 224, height: 224)) else {
            return
        }

        guard let buffer = resizedImage.buffer, let analysisResults = ImageAnalysisResults.createFromPixelBuffer(buffer) else {
            return
        }

        // Update UI from analysis results
        whatIsThisLabel.text = analysisResults.analysisObjectType
        let confidencePercentage = String(format: "%\(0.2)f", analysisResults.confidence * 100)
        confidenceLabel.text = "Confidence: \(confidencePercentage)%"
    }
}

extension ImagePickerViewController : UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        imageView.contentMode = .scaleAspectFit
        imageView.image = pickedImage

        analyzeImage(pickedImage)

        dismiss(animated:true, completion: nil)
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}
