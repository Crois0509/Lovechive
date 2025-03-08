//
//  UserDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

struct UserDataModel: FirestoreModelProtocol {
    let name: String
    let email: String
    let coupleId: String
    let birthDay: Date
    let createdAt: Date
    
    func transform() -> [String: Any] {
        return [
            "name": self.name,
            "email": self.email,
            "coupleId": self.coupleId,
            "birthDay": self.birthDay,
            "createdAt": self.createdAt
        ]
    }
}
