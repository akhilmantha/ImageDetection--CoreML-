//
//  ViewController.swift
//  SceneDetector
//
//  Created by akhil mantha on 12/06/17.
//  Copyright © 2017 akhil mantha. All rights reserved.


import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var scene: UIImageView!
  @IBOutlet weak var answerLabel: UILabel!

  // MARK: - Properties
  let vowels: [Character] = ["a", "e", "i", "o", "u"]

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let image = UIImage(named: "train_night") else {
      fatalError("no starting image")
    }

    scene.image = image
    detectScene(image: ciImage)
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func pickImage(_ sender: Any) {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    pickerController.sourceType = .savedPhotosAlbum
    present(pickerController, animated: true)
  }
}
extension ViewController{
  
  func detectScene(image: CIImage){
    answerLabel.text = "detecting scenes....."
    
    //load ml model through its generated class
    guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else{
      fatalError("can't load ml model")
    }
    let request = VNCoreMLRequest(model: model) {[weak self]request , Error in
       guard let results = request.results as? [VNClassificationObservation],
        let topResult = results.first else{
          fatalError("unexpected result type from vncoremlrequest")
    }
      //update the ui ont he main queue
      let article = (self?.vowels.contains(topResult.identifier.first!))! ? "an" : "a"
      DispatchQueue.main.async {[weak self] in
        self?.answerLabel.text = "\(Int(topResult.confidence * 100))%it's \(article) \(topResult.identifier)"}
        
      }
    //to run the model
    let handler = VNImageRequestHandler(ciImage : image)
    DispatchQueue.global(qos: .userInteractive).async {
      do{
        try handler.perform([request])
      }catch{
        print(error)
      }
    }
      }
    
  }


/// MARK: - UIImagePickerControllerDelegate

extension ViewController: UIImagePickerControllerDelegate {

  func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    dismiss(animated: true)

    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      fatalError("couldn't load images from ")
    }

    scene.image = image
  }
  guard let ciImage = CIImage(image: image) else {
  fatalError("couldn't convert ciimage to uiimage")
  }
  detectScene(image: ciImage)
}

// /MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}
