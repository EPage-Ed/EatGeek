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
            
            let cvWrapper = OpenCVWrapper()

            let img = cvWrapper.preprocessImage(image)
            tesseract.image = img
            tesseract.recognize()
            delegate?.result(text: tesseract.recognizedText)
        }
        
    }
}
