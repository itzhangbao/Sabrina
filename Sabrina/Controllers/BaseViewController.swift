//
//  BaseViewController.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/7.
//

import UIKit

@objc class BaseViewController: UIViewController {

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
