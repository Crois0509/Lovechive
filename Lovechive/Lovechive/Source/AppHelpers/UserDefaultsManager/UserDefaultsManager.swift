//
//  UserDefaultsManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import Foundation

/// UserDefaults를 관리하는 객체
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
    
    /// UserDefaults에 데이터를 저장하는 메소드
    /// - Parameter data: 저장할 데이터
    func saveToUserDefaults<T>(_ data: T) {
        UserDefaults.standard.set(data, forKey: "\(data.self)")
    }
    
    /// UserDefaults에서 데이터를 불러오는 메소드
    /// - Parameter key: 불러올 데이터의 Key
    /// - Returns: Key에 해당하는 데이터
    func loadFromUserDefaults(_ key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
}
