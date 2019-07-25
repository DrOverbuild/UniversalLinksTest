//
//  ImageDetailViewController.swift
//  UniversalLinksTest
//
//  Created by Jasper on 7/24/19.
//  Copyright © 2019 Jasper. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    var image: UIImage!
    var details = ""
    
    @IBOutlet var mainImageView: UIImageView!
    
    @IBOutlet var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainImageView.image = image
        detailsLabel.text = details
        
        // Do any additional setup after loading the view.
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
