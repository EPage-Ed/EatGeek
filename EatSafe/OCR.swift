//
//  OCR.swift
//  EatSafe
//
//  Created by Edward Arenberg on 12/1/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

import UIKit
import TesseractOCRSDKiOS
import GPUImage


protocol OCRDelegate: class {
    func result(text:String)
}

class OCR {
    var delegate : OCRDelegate?
    
    func processImage(image: UIImage) {

        if let tesseract = MGTesseract(language: "eng") {
            tesseract.engineMode = .cubeOnly
            tesseract.pageSegmentationMode = .auto
            
            // Initialize our adaptive threshold filter
        
            let stillImageFilter = GPUImageAdaptiveThresholdFilter()
            stillImageFilter.blurRadiusInPixels = 4.0 // adjust this to tweak the blur radius of the filter, defaults to 4.0
            
            // Give Tesseract the filtered image
            tesseract.image = stillImageFilter.image(byFilteringImage: image)
            tesseract.recognize()
            delegate?.result(text: tesseract.recognizedText)
        }
        
    }
}
