//
//  UserDefaultsManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import Foundation

struct UserDefaultsManager {
    
    var userId: String {
        guard let id = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.userId) else {
            return ""
        }
        
        return id
    }
    
    var coupleId: String {
        guard let id = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId) else {
            return ""
        }
        
        return id
    }
    
    
}
