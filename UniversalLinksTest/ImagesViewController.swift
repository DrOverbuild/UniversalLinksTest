//
//  ImagesViewController.swift
//  UniversalLinksTest
//
//  Created by Jasper on 7/24/19.
//  Copyright © 2019 Jasper. All rights reserved.
//

import UIKit
import Firebase

class ImagesViewController: UITableViewController {

    var images = [UIImage]()
    
    var labels: [Int: [VisionImageLabel]] = [:]
    
    var labeler: VisionImageLabeler!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let options = VisionCloudImageLabelerOptions()
        options.confidenceThreshold = 0.7
        self.labeler = Vision.vision().cloudImageLabeler(options: options)
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
}

extension ImagesViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            let vImg = VisionImage(image: image)
            self.labeler.process(vImg) { labels, error in
                guard error == nil, let labels = labels else {
                    print(error)
                    return
                }
                
                self.images.append(image)
                self.tableView.reloadData()
                self.labels[self.images.count - 1] = labels
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ImagesViewController: UINavigationControllerDelegate {
    
}
