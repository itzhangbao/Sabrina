//
//  UIDevice++.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/6.
//

import UIKit

// MARK: - 屏幕相关
extension UIDevice {
    
    /// 屏幕宽度
    open class func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// 屏幕高度
    open class func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    /// 是否为刘海屏
    open class func isBangs() -> Bool {
        return phoneAreaBottom() > 0
    }
    
    /// 刘海屏安全区域-上
    open class func phoneAreaTop() -> CGFloat {
        return UIWindow.current()?.safeAreaInsets.top ?? 0.0
    }
    
    /// 刘海屏安全区域-左
    open class func phoneAreaLeft() -> CGFloat {
        return UIWindow.current()?.safeAreaInsets.left ?? 0.0
    }
    
    /// 刘海屏安全区域-下
    open class func phoneAreaBottom() -> CGFloat {
        return UIWindow.current()?.safeAreaInsets.bottom ?? 0.0
    }
    
    /// 刘海屏安全区域-右
    open class func phoneAreaRight() -> CGFloat {
        return UIWindow.current()?.safeAreaInsets.right ?? 0.0
    }
}
