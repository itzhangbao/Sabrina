//
//  KeysConfig.swift
//  Sabrina
//
//  Created by Jumbo on 2021/2/8.
//

enum KeysConfig {
    case im
    case map

    var appid: String {
        switch self {
        case .im: return "1400485231"
        case .map: return "f2e4c9953b8a6468c9e5768f30f9e80b"
        }
    }
    
    var secret: String {
        switch self {
        case .im: return "105602822ef03154e1f01e2c3339dc62bad09b2a9f1eaf58c5abdc0c37c5e3ff"
        case .map: return ""
        }
    }
}
