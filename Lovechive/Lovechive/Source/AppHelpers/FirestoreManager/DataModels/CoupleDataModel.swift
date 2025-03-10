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
    let user1: String
    let user2: String
    let dDay: Date
    
    func transform() -> [String : Any] {
        return [
            AppConfig.CouplesModel.user1: self.user1,
            AppConfig.CouplesModel.user2: self.user2,
            AppConfig.CouplesModel.dDay: Timestamp(date: self.dDay)
        ]
    }
}
