//
//  UserPhoto.swift
//  EatSafe
//
//  Created by Edward Arenberg on 12/1/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

import UIKit
import CameraManager
import Parse

protocol CameraDelegate : class {
    func addImage(image:UIImage,file:PFFile)
    func addPhoto(photo:UserPhoto)
}

extension CameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // UIImagePickerControllerEditedImage UIImagePickerControllerOriginalImage
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dismiss(animated: true, completion: nil )
            return
        }
        print(image)
        self.myImage = image
        dismiss(animated: true, completion: {
            self.camState = .pic
        })
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

class CameraVC: UIViewController {
    
    enum CamState { case take,pic }
    var camState : CamState = .take {
        didSet {
            switch camState {
            case .take:
                break
            case .pic:
                libraryButton.isHidden = true
                camButton.isHidden = true
                flashButton.isHidden = true
                takeButton.setImage(UIImage(named:"Photo_Trigger_Taken_Icon"), for: .normal)
            }
        }
    }

    weak var delegate : CameraDelegate?
    
    let cameraManager = CameraManager()
    var myImage : UIImage? {
        didSet {
            myImageView = UIImageView(frame: view.bounds)
            myImageView?.contentMode = .scaleAspectFill
            myImageView?.image = myImage
            cameraView.addSubview(myImageView!)
        }
    }
    var myImageView : UIImageView?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var flashButton: UIButton! {
        didSet {
            flashButton.layer.cornerRadius = flashButton.bounds.size.height / 2
            flashButton.layer.masksToBounds = true
        }
    }
    @IBAction func flashHit(_ sender: UIButton) {
        let mode = cameraManager.changeFlashMode()
        switch mode {
        case .auto:
            flashButton.setImage(nil, for: .normal)
            flashButton.setTitle("Auto", for: .normal)
        case .off:
            flashButton.setImage(UIImage(named:"Flash_Off_Icon"), for: .normal)
            flashButton.setTitle("", for: .normal)
        case .on:
            flashButton.setImage(UIImage(named:"Flash_On_Icon"), for: .normal)
            flashButton.setTitle("", for: .normal)
        }
    }
    
    @IBOutlet weak var camButton: UIButton!
    @IBAction func camHit(_ sender: UIButton) {
        if cameraManager.cameraDevice == .back {
            cameraManager.cameraDevice = .front
        } else {
            cameraManager.cameraDevice = .back
        }
    }
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBAction func libraryHit(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.delegate = self
        vc.sourceType = .photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func cancelHit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var takeButton: UIButton!
    @IBAction func takeHit(_ sender: UIButton) {
        if camState == .take {
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                guard let image = image else { return }
                if self.cameraManager.cameraDevice == .front {
                    self.myImage = image
                } else {
                    self.myImage = image
                }
                
                self.camState = .pic
            })
        } else {
            guard let img = myImage else { return }
            let image = img.resizeImage(300, opaque: true)
            guard let d = UIImageJPEGRepresentation(image,0.9) else { return }
            spinner.startAnimating()
            self.view.window?.alpha = 0.5
            self.view.window?.isUserInteractionEnabled = false
            let f = PFFile(data: d, contentType: "image/png")
            f.saveInBackground(block: { success, error in
                if success {
                    self.delegate?.addImage(image: image, file:f)
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.view.window?.alpha = 1.0
                        self.view.window?.isUserInteractionEnabled = true
                        self.dismiss(animated: true, completion: nil )
                    }

                } else {
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.view.window?.alpha = 1.0
                        self.view.window?.isUserInteractionEnabled = true
                        let ac = UIAlertController(title: "Not Saved", message: error?.localizedDescription ?? "", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                    }
                }
            })

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cameraManager.addPreviewLayerToView(self.cameraView)

        cameraManager.cameraDevice = .front
        //                    self.cameraManager.shouldEnableTapToFocus = true
        //                    self.cameraManager.shouldEnablePinchToZoom = true
        // cameraManager.shouldUseLocationServices = true
        //                    self.cameraManager.cameraOutputMode = .stillImage
        //                    self.cameraManager.cameraOutputQuality = .high
        //                    self.cameraManager.focusMode = .continuousAutoFocus
        //                    self.cameraManager.exposureMode = .continuousAutoExposure
        //                    self.cameraManager.flashMode = .off
        //                    self.cameraManager.writeFilesToPhoneLibrary = true
        // cameraManager.animateShutter = true
        cameraManager.shouldFlipFrontCameraImage = true
        //                    self.cameraManager.animateCameraDeviceChange = true
        //                    self.cameraManager.showAccessPermissionPopupAutomatically = true
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
