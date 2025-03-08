//
//  CoupleDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

struct CoupleDataModel: FirestoreModelProtocol {
    let user1: String
    let user2: String
    let dDay: Date
    
    func transform() -> [String : Any] {
        return [
            "user1": self.user1,
            "user2": self.user2,
            "dDay": self.dDay
        ]
    }
}
