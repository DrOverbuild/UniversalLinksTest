//
//  MainNavController.swift
//  UniversalLinksTest
//
//  Created by Jasper on 7/24/19.
//  Copyright © 2019 Jasper. All rights reserved.
//

import UIKit

class MainNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
