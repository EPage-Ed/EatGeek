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
import HealthKit
import CameraManager

class ViewController: UIViewController {

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var dataLabel: UILabel! {
        didSet {
            dataLabel.layer.cornerRadius = 8
            dataLabel.layer.masksToBounds = true
        }
    }
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
    
    @IBOutlet weak var camButton: UIButton! {
        didSet {
            camButton.layer.cornerRadius = 10
            camButton.layer.masksToBounds = true
        }
    }
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
    
    let infoData = [
        "LOADED FRIES\nCalories: 1100\nCarbs: 95g\nSugars: 6g",
        "SPINACH FLORENTINE FLATBREAD\nCalories: 550\nCarbs: 51g\nSugars: 4g",
        "BBQ CHICKEN FLATBREAD\nCalories: 650\nCarbs: 66g\nSugars: 18g",
        "CRISPY BRUSSELS SPROUTS\nCalories: 670\nCarbs: 38g\nSugars: 8g",
        "GIANT ONION RINGS\nCalories: 690\nCarbs: 155g\nSugars: 33g"
    ]
    
    let infoColors = [ 2, 0, 1, 0, 1 ]
    
    func showInfo(index:Int) {
        infoLabel.text = infoData[index]
        infoHeightConstraint.constant = 180
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func hideInfo() {
        infoLabel.text = ""
        infoHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraManager.addPreviewLayerToView(cameraView)
        cameraManager.cameraDevice = .back
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.shouldRespondToOrientationChanges = true
        cameraManager.animateShutter = true
        
        infoHeightConstraint.constant = 0
        view.layoutIfNeeded()
        
        let heartRateType: HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        HKHealthStore().requestAuthorization(toShare: nil, read: [heartRateType]) {(success, error) in
            print(success)
            //Success will always be equal to true unless a genuine error occurs
            self.getHeartRateData()
        }

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
                var transform = CGAffineTransform.identity // .rotated(by: .pi/2)
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
            UIColor.yellow.withAlphaComponent(0.2).cgColor,
            UIColor.blue.withAlphaComponent(0.2).cgColor,
            UIColor.magenta.withAlphaComponent(0.2).cgColor,
            UIColor.cyan.withAlphaComponent(0.2).cgColor,
            UIColor.orange.withAlphaComponent(0.2).cgColor
        ]
        for (i,ms) in menuSets.enumerated() {
            let f = ms.first
            var x : CGFloat = f?.1.frame.origin.x ?? 0
            var y : CGFloat = f?.1.frame.origin.y ?? 0
            var r : CGFloat = f?.1.frame.maxX ?? 0
            var b : CGFloat = f?.1.frame.maxY ?? 0
            for vl in ms {
                let idx = infoColors[i % infoColors.count]
                vl.1.backgroundColor = bg[idx] // bg[i % bg.count]
                x = min(x,vl.1.frame.origin.x)
                y = min(y,vl.1.frame.origin.y)
                r = max(r,vl.1.frame.maxX)
                b = max(b,vl.1.frame.maxY)
            }
            let rect = CGRect(x: x, y: y, width: r-x, height: b-y)
            let v = UIView(frame: rect)
            v.tag = i
            let t = UITapGestureRecognizer(target: self, action: #selector(menuTapped(_:)))
            v.addGestureRecognizer(t)
            v.backgroundColor = UIColor.clear
            imageView.addSubview(v)
        }
        
        // delegate?.boxService(self, didDetect: images)
    }
    
    @objc func menuTapped(_ sender:UITapGestureRecognizer) {
        guard let v = sender.view else { return }
        print(v.tag)
        if v.tag < infoData.count {
            showInfo(index: v.tag)
        }
    }
    @IBAction func infoTapped(_ sender: UITapGestureRecognizer) {
        hideInfo()
    }
    
    private func reset() {
        layers.forEach {
            $0.removeFromSuperlayer()
        }
        layers.removeAll()
        menuSets.removeAll()
        imageView.subviews.forEach {
            $0.removeFromSuperview()
        }
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


    
    
    
    let health = HKHealthStore()
    let heartRateType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var shownWarning : Bool = true
    
    func getHeartRateData() {
        let startDate = Calendar.current.date(byAdding: .day, value: -400, to: Date())!
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        ]
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                           predicate: predicate,
                                           limit: HKObjectQueryNoLimit,
                                           sortDescriptors: sortDescriptors)
        { (query:HKSampleQuery, results:[HKSample]?, error:Error?) -> Void in
            guard let results = results else { return }
            if results.count == 0 && !self.shownWarning {
                self.shownWarning = true
                DispatchQueue.main.async {
                    self.showNilError()
                }
            } else if let r = results.first {
                let val = r.metadata
                print(val)
            }
        }
        health.execute(heartRateQuery)
    }
    
    func showNilError() {
        let alert = UIAlertController(title: "No Heart Rate Data Found", message: "There was no heart rate data found for the selected dates. If you expected to see data, it may be that HeartRate is not authorised to read you heart rate data. Please go to the settings app (Privacy -> HealthKit) to change this.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler:  { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

