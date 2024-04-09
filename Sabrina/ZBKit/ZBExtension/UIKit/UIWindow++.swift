//
//  UIWindow++.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/6.
//

import Foundation
import UIKit

extension UIWindow {
    class open func current() -> UIWindow? {
        if let window = UIApplication.shared.delegate?.window, window != nil {
            return window
        }else {
            if #available(iOS 13.0, *) {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene: UIWindowScene = scenes.first as! UIWindowScene
                
                let delegate: SceneDelegate = windowScene.delegate as! SceneDelegate
                let mainWindow = delegate.window
                
                if let window = mainWindow {
                    return window
                }else {
                    return UIApplication.shared.windows.last
                }
            }else {
                return UIApplication.shared.keyWindow
            }
        }
    }
}
