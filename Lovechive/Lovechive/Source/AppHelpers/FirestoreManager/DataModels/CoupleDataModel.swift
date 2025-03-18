//
//  CoupleDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import FirebaseFirestore

/// Firestore의 couples 컬렉션 데이터 모델
struct CoupleDataModel: FirestoreModelProtocol {
    let user1Id: String
    let user2Id: String
    let user1Name: String
    let user2Name: String
    let dDay: Date
    
    func transform() -> [String : Any] {
        return [
            AppConfig.CouplesModel.user1Id: self.user1Id,
            AppConfig.CouplesModel.user2Id: self.user2Id,
            AppConfig.CouplesModel.user1Name: self.user1Name,
            AppConfig.CouplesModel.user2Name: self.user2Name,
            AppConfig.CouplesModel.dDay: Timestamp(date: self.dDay)
        ]
    }
}
