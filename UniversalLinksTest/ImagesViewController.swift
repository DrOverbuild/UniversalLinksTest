//
//  ImagesViewController.swift
//  UniversalLinksTest
//
//  Created by Jasper on 7/24/19.
//  Copyright © 2019 Jasper. All rights reserved.
//

import UIKit
import Firebase
import Vision
import FirebaseMLCommon

class ImagesViewController: UITableViewController {

    var images = [UIImage]()
    
    var labels: [Int: [VisionImageLabel]] = [:]
    var modelOutput: [Int: SportsImageClassifierOutput] = [:]
    
    var labeler: VisionImageLabeler!
    var model: SportsImageClassifier!
    var modelManager: ModelManager!
    
    var vSpinner: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        let options = VisionCloudImageLabelerOptions()
//        options.confidenceThreshold = 0.7
//        self.labeler = Vision.vision().cloudImageLabeler(options: options)
        self.model = SportsImageClassifier()
        
        let labelerOptions = VisionOnDeviceAutoMLImageLabelerOptions(
            remoteModelName: "SportsImageClass",  // Or nil to not use a remote model
            localModelName: nil                   // Or nil to not use a bundled model
        )
        labelerOptions.confidenceThreshold = 0  // Evaluate your model in the Firebase console
        // to determine an appropriate value.
        labeler = Vision.vision().onDeviceAutoMLImageLabeler(options: labelerOptions)
        modelManager = ModelManager.modelManager()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return images.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell

        // Configure the cell...
        cell.mainImageView?.image = images[indexPath.row]
        cell.labels = self.labels[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completed in
            self.images.remove(at: indexPath.row)
            self.labels.removeValue(forKey: indexPath.row)
            self.modelOutput.removeValue(forKey: indexPath.row)
            completed(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "imageDetailsController") as? ImageDetailViewController {
            vc.image = images[indexPath.row]
            
            var details = ""
            
            for label in labels[indexPath.row] ?? [] {
                let confidence = label.confidence ?? NSNumber(integerLiteral: 0)
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 3

                details += "\(label.text): \(formatter.string(from: confidence) ?? 0.description)\n"
            }
            
//            if let output = self.modelOutput[indexPath.row] {
//                for (key, value) in output.classLabelProbs {
//                    let confidence = NSNumber(value: value) ?? NSNumber(integerLiteral: 0)
//                    let formatter = NumberFormatter()
//                    formatter.maximumFractionDigits = 3
//                    details += "\(key): \(formatter.string(from: confidence) ?? 0.description)\n"
//                }
//            }
            
            vc.details = details
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func addImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true)
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func showProgress() {
        let spinnerView = UIView.init(frame: self.view.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view!.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func hideProgress() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}

extension ImagesViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            self.showProgress()
            
//            let smImg = UIImage.resize(image: image, targetSize: CGSize(width: 300, height: 300))
            
            let vImg = VisionImage(image: image)
            
            
            
            if let remoteModel = modelManager.remoteModel(withName: "SportsImageClass") {
                if modelManager.isRemoteModelDownloaded(remoteModel) {
                    self.labeler.process(vImg) { labels, error in
                        guard error == nil, let labels = labels else {
                            print(error)
                            self.hideProgress()
                            return
                        }
                        
                        self.images.append(image)
                        self.labels[self.images.count - 1] = labels
                        self.tableView.reloadData()
                        self.hideProgress()
                        
                        //                if let model = self.model,
                        //                    let buffer = self.buffer(from: smImg){
                        //                    do {
                        //                        let output = try model.prediction(image: buffer)
                        //                        self.modelOutput[self.images.count - 1] = output
                        //                        self.images.append(image)
                        //                        self.tableView.reloadData()
                        //                        self.hideProgress()
                        //                    } catch {
                        //                        print("Unable to categorize image")
                        //                        self.hideProgress()
                        //                    }
                        //                }
                    }
                } else {
                    self.hideProgress()
                    picker.dismiss(animated: true, completion: nil)
                    let alertController = UIAlertController(title: "Not downloaded", message: "Model not downloaded", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(okAction)
                }
            }
            
           
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagesViewController: UINavigationControllerDelegate {
    
}

extension UIImage {
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        var newSize: CGSize
        
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    class func scale(image: UIImage, by scale: CGFloat) -> UIImage? {
        let size = image.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIImage.resize(image: image, targetSize: scaledSize)
    }
}
