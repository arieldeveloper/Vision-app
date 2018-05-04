//
//  ViewController.swift
//  Vision-app
//
//  Created by Ariel Chouminov on 2018-05-02.
//  Copyright © 2018 Ariel Chouminov. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashState {
    case off
    case on
}
class CameraVC: UIViewController {

    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var photoData: Data?
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    
    var flashControlState: FlashState = .off
    
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var identificationLabel: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var flashBtn: RoundedShadowBtn!
    @IBOutlet weak var CaptureImageView: RoundedShadowImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        //camera output preview layer
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        //uses default which is back camera
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        //set up input to pass into the model
        do {
            //passing input
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(cameraOutput) {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                //
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
            
        } catch {
            debugPrint(error)
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
    
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?)  {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        for classification in results {
            if classification.confidence < 0.5 {
                self.identificationLabel.text = "I'm not sure what this is, please try again"
                self.confidenceLbl.text = ""
                break
            } else {
                self.identificationLabel.text = classification.identifier
                self.confidenceLbl.text = "Confidence: \(Int(classification.confidence * 100))%"
                break
            }
        }
    }
    
    @IBAction func flashButtonWasPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashBtn.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on:
            flashBtn.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
    }
}


extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            do {
               //handle errors
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            let image = UIImage(data: photoData!)
            self.CaptureImageView.image = image
            
        }
    }
}

extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //code to finish uterance
    }
}

