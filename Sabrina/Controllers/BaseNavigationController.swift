//
//  BaseNavigationController.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/9.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool { return true }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
