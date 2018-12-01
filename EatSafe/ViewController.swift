//
//  ViewController.swift
//  EatSafe
//
//  Created by Edward Arenberg on 12/1/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import CameraManager

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    let cameraManager = CameraManager()
    var myImage : UIImage? {
        didSet {
            imageView.alpha = 0
            imageView.image = myImage
            UIView.animate(withDuration: 0.25) {
                self.imageView.alpha = 1
            }
            processImage(image: myImage!)
        }
    }
    @IBAction func imageTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.imageView.alpha = 0
        }
    }
    
    @IBOutlet weak var camButton: UIButton!
    @IBAction func takeHit(_ sender: UIButton) {
        cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
            guard let image = image else { return }
            if self.cameraManager.cameraDevice == .front {
                self.myImage = image
            } else {
                self.myImage = image
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraManager.addPreviewLayerToView(cameraView)
        cameraManager.cameraDevice = .back
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.shouldRespondToOrientationChanges = true

    }
    
    func processImage(image:UIImage) {
        guard let cgImage = image.cgImage else {
            assertionFailure()
            return
        }
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: inferOrientation(image: image),
            options: [VNImageOption: Any]()
        )
        
        let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handle(image: image, request: request, error: error)
            }
        })
        
        request.reportCharacterBoxes = true
        
        do {
            try handler.perform([request])
        } catch {
            print(error as Any)
        }

    }


    private func handle(image: UIImage, request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNTextObservation] else {
            return
        }
        
        // delegate?.visionService(self, didDetect: image, results: results)
        print(results)
    }
    
    
    private func inferOrientation(image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up:
            return CGImagePropertyOrientation.up
        case .upMirrored:
            return CGImagePropertyOrientation.upMirrored
        case .down:
            return CGImagePropertyOrientation.down
        case .downMirrored:
            return CGImagePropertyOrientation.downMirrored
        case .left:
            return CGImagePropertyOrientation.left
        case .leftMirrored:
            return CGImagePropertyOrientation.leftMirrored
        case .right:
            return CGImagePropertyOrientation.right
        case .rightMirrored:
            return CGImagePropertyOrientation.rightMirrored
        }
    }


}

