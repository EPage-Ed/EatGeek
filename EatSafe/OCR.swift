//
//  OCR.swift
//  EatSafe
//
//  Created by Edward Arenberg on 12/1/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

import Foundation

protocol OCRDelegate: class {
    func result(text:String)
}

class OCR {
    var delegate : OCRDelegate?
    
    
}
