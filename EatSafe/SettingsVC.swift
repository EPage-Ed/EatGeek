//
//  SettingsVC.swift
//  EatSafe
//
//  Created by Edward Arenberg on 12/2/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var dietSV: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        populateDiets()
    }
    
    let diets = [
        "Diabetes",
        "Kidney (Renal)",
        "Chron's",
        "Colitis",
        "Ciliac",
        "Hypertension",
        "Allergens"
    ]
    
    func populateDiets() {
        let sz : CGFloat = 80
        if dietSV == nil { return }
        for (i,d) in diets.enumerated() {
            let y : CGFloat = CGFloat(i) * sz + 10
            let b = CheckButton(frame: CGRect(x: 0, y: y, width: sz-10, height: sz-10))
            b.tag = 10+i
            b.addTarget(self, action: #selector(dietButtonHit(_:)), for: .touchUpInside)
            b.isChecked = i == 0
            dietSV.addSubview(b)
            let l = UILabel(frame: CGRect(x: sz, y: y, width: dietSV.bounds.size.width - sz, height: sz-10))
            l.font = UIFont.systemFont(ofSize: 32)
            l.textColor = .white
            l.text = d
            dietSV.addSubview(l)
        }
        dietSV.contentSize = CGSize(width: dietSV.bounds.size.width, height: CGFloat(diets.count) * sz + 20)
    }
    @objc func dietButtonHit(_ b:CheckButton) {
        b.isChecked = !b.isChecked
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
