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
        
        print(results)
        
        handleVisionResults(
            cameraLayer: imageView.layer,
            image: image,
            results: results,
            on: imageView
        )

    }
    
    private var layers: [CALayer] = []
    private var menuSets = [[(UIImage,CALayer)]]()
    
    func handleVisionResults(cameraLayer: CALayer, image: UIImage, results: [VNTextObservation], on view: UIView) {
        reset()
        
        let results = results.filter{ $0.confidence > 0.5 }
        var images = [UIImage]()
        
        layers = results.compactMap({ result in
            let layer = CALayer()
            view.layer.addSublayer(layer)
            // layer.borderWidth = 2
            // layer.backgroundColor = UIColor.yellow.withAlphaComponent(0.2).cgColor
            // layer.borderColor = UIColor.green.cgColor
            
            do {
                var transform = CGAffineTransform.identity
                transform = transform.scaledBy(x: image.size.width, y: -image.size.height)
                transform = transform.translatedBy(x: 0, y: -1)
                let rect = result.boundingBox.applying(transform)
                
                let scaleUp: CGFloat = 0.2
                let biggerRect = rect.insetBy(
                    dx: -rect.size.width * scaleUp,
                    dy: -rect.size.height * scaleUp
                )
                
                if let croppedImage = crop(image: image, rect: biggerRect) {
                    images.append(croppedImage)
                    // print(croppedImage)
                } else {
                    print("Skip: \(result.boundingBox)")
                    return nil
                }

            }
            
            do {
                // print(result.boundingBox)
                
                // Convert found bounding box to frame in displayed image (using aspect fit)
                
                let f = view.bounds
                let w = f.width
                let h = f.height

                let aspect = image.size.height / image.size.width
                let imgH = w * aspect
                let imgY = (h - imgH) / 2
                
                let b = result.boundingBox
                let lx = w * b.origin.x
                let ly = (imgH - (imgH * b.origin.y)) + imgY * (imgH / h) // Origin is flipped
                let lw = w * b.size.width
                let lh = h * b.size.height
                
                layer.frame = CGRect(x: lx, y: ly, width: lw, height: lh)
                print(layer.frame)
                
                // let rect = cameraLayer.layerRectConverted(fromMetadataOutputRect: result.boundingBox)
                // layer.frame = rect
            }
            
            return layer
        })

        // Integrate groups of text blocks into a menu item
        var y = CGFloat(-100)
        var ms = [(UIImage,CALayer)]()
        for (i,l) in layers.enumerated() {
            let img = images[i]
            if l.frame.origin.y > y + 4 {
                print("\(ms.count) Gap: \(l.frame.origin.y - y)")
                if !ms.isEmpty {
                    self.menuSets.append(ms)
                }
                ms = [(UIImage,CALayer)]()
                y = l.frame.maxY
            }
            ms.append((img,l))
            y = max(l.frame.maxY,y)
            if i >= layers.count-1 && !ms.isEmpty {
                print("\(ms.count) Gap: \(l.frame.origin.y - y)")
                self.menuSets.append(ms)
            }
        }

        // print(menuSets)

        let bg = [
            UIColor.green.withAlphaComponent(0.2).cgColor,
            UIColor.red.withAlphaComponent(0.2).cgColor,
            UIColor.blue.withAlphaComponent(0.2).cgColor,
            UIColor.magenta.withAlphaComponent(0.2).cgColor,
            UIColor.cyan.withAlphaComponent(0.2).cgColor,
            UIColor.orange.withAlphaComponent(0.2).cgColor
        ]
        for (i,ms) in menuSets.enumerated() {
            for vl in ms {
                vl.1.backgroundColor = bg[i % bg.count]
            }
        }
        
        // delegate?.boxService(self, didDetect: images)
    }
    
    private func reset() {
        layers.forEach {
            $0.removeFromSuperlayer()
        }
        layers.removeAll()
        menuSets.removeAll()
    }
    
    private func crop(image: UIImage, rect: CGRect) -> UIImage? {
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
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

