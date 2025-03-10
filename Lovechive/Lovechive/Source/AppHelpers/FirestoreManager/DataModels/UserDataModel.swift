//
//  UserDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import FirebaseFirestore

/// Firestore의 users 컬렉션 데이터 모델
struct UserDataModel: FirestoreModelProtocol {
    let name: String
    let email: String
    let coupleId: String
    let birthDay: Date
    let createdAt: Date
    
    func transform() -> [String: Any] {
        return [
            AppConfig.UserModel.name: self.name,
            AppConfig.UserModel.email: self.email,
            AppConfig.UserModel.coupleId: self.coupleId,
            AppConfig.UserModel.birthDay: Timestamp(date: self.birthDay),
            AppConfig.UserModel.createdAt: Timestamp(date: self.createdAt)
        ]
    }
}
