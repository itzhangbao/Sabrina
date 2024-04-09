//
//  LibsManager.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/8.
//

import Foundation

class LibsManager: NSObject {
    static let shared: LibsManager = LibsManager()
    private override init() { super.init() }
    
    open func setupLibs() {
        setupMap()
        setupIM()
    }
    
    private func setupIM() {
        IMManger.shared().setupSDK()
    }
    
    private func setupMap() {
        AMapServices.shared().apiKey = KeysConfig.map.appid
        AMapServices.shared().enableHTTPS = true
        MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
        MAMapView.updatePrivacyShow(AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
    }
}
