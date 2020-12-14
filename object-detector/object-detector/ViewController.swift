//
//  ViewController.swift
//  object-detector
//
//  Created by shiba on 2020/12/9.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    // DONE: Define lazy var classificationRequest
    lazy var classificationRequest: VNCoreMLRequest = {
        // Load the ML model through its generated class and create a Vision request for it.
        //        print(Detector().model)
        guard let model = try? VNCoreMLModel(for: Detector().model) else {
            fatalError("miss error when load model")
        }
        let request = VNCoreMLRequest(model: model, completionHandler: processObservations)
        request.imageCropAndScaleOption = .scaleFill
        
        return request
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func camera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        resultLabel.text = "Analyzing Image..."
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        classify(image: image)
        imageView.image = image
        
    }
    
    func classify(image: UIImage) {
        if let cgImage = image.cgImage {
            DispatchQueue.main.async {
                let handler = VNImageRequestHandler(cgImage: cgImage)
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    print("Failed to perform classification: \(error)")
                }
            }
        }
    }
}

let labels = ["apple", "banana", "cake", "candy", "carrot", "cookie",
              "doughnut", "grape", "hot dog", "ice cream", "juice",
              "muffin", "orange", "pineapple", "popcorn", "pretzel",
              "salad", "strawberry", "waffle", "watermelon"]

extension ViewController {
    
    func processObservations(for request: VNRequest, error: Error?) {
        if let results = request.results as? [VNCoreMLFeatureValueObservation] {
            if results.isEmpty {
                self.resultLabel.text = "Nothing found"
            } else {
                if let probs = results[0].featureValue.multiArrayValue, let bbox = results[1].featureValue.multiArrayValue {
                    var maxProb = 0.0, maxIndex = -1
                    for index in 0..<probs.count {
                        if probs[index].doubleValue > maxProb {
                            maxProb = probs[index].doubleValue
                            maxIndex = index
                        }
                    }
//                    print(maxProb, maxIndex)
                    self.resultLabel.text = labels[maxIndex] + String(format: " with prob %.1f%%", maxProb * 100)
//                    print(bbox)
                    self.imageView.image = self.imageView.image?.addBoundingBox(x_min: bbox[0].doubleValue, x_max: bbox[1].doubleValue, y_min: bbox[2].doubleValue, y_max: bbox[3].doubleValue)
//                    print(type(of: bbox[0]))
                }
                //                  let result = results[0].identifier
                //                  let confidence = results[0].confidence
                //                  self.resultLabel.text = result + String(format: "%.1f%%", confidence * 100)
                //                  print(result)
            }
        } else if let error = error {
            self.resultLabel.text = "Error: \(error.localizedDescription)"
        } else {
            self.resultLabel.text = "???"
        }
    }
}

extension UIImage {
    func addBoundingBox(x_min: Double, x_max: Double, y_min: Double, y_max: Double)->UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: CGPoint(x: 0, y: 0))
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(UIColor.green.cgColor)
            context.setLineWidth(10)
            let x = x_min * Double(self.size.width), y = y_min * Double(self.size.height), width = (x_max - x_min) * Double(self.size.width), height = (y_max - y_min) * Double(self.size.height)
            context.addRect(CGRect(x: x, y: y, width: width, height: height))
            context.strokePath()
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
