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

    private let picker = UIImagePickerController()

    override func viewDidLoad() {

        super.viewDidLoad()
        picker.delegate = self
    }

    @IBAction func photoFromLibrary(_ sender: UIBarButtonItem) {

        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }

    func analyzeImage(_ pixelBuffer: CVPixelBuffer) {

        do {

            let resnetModel = Resnet50()
            
            // Get the model's prediction
            let output = try resnetModel.prediction(image: pixelBuffer)

            // Sort results
            let sorted = output.classLabelProbs.sorted(by: { (lhs, rhs) -> Bool in

                return lhs.value > rhs.value
            })

            whatIsThisLabel.text = sorted[0].key

            let confidencePercentage = String(format: "%\(0.2)f", sorted[0].value * 100)
            confidenceLabel.text = "Confidence: \(confidencePercentage)%"

        } catch {

            print(error)
        }
    }
}

extension ImagePickerViewController : UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        // The input image size should be 224x224 for ResNet
        guard let imageForAnalysis = pickedImage.resize(size: CGSize(width: 224, height: 224)) else {
            return
        }

        imageView.contentMode = .scaleAspectFit
        imageView.image = pickedImage

        if let buffer = imageForAnalysis.buffer {
            analyzeImage(buffer)
        }

        dismiss(animated:true, completion: nil)
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}
