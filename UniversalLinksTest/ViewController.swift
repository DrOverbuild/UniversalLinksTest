//
//  ViewController.swift
//  UniversalLinksTest
//
//  Created by Jasper on 7/24/19.
//  Copyright © 2019 Jasper. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    var eventualData = "I'm a cow"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate,
            let string = delegate.eventualData{
            
            self.eventualData = string
        } else {
            self.eventualData = Date(timeIntervalSinceNow: 0).description
        }
        
        self.label.text = eventualData
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

