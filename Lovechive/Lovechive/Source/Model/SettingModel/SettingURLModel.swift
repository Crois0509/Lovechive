//
//  SettingURLModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/27/25.
//

import Foundation

enum SettingURLModel {
    case privacyInfo
    case playInfo
    case review
    case bug
    
    var urlString: String {
        switch self {
        case .privacyInfo:
            return ""
        case .playInfo:
            return ""
        case .review:
            return AppConfig.SettingConfig.appstoreLink
        case .bug:
            return ""
        }
    }
}
