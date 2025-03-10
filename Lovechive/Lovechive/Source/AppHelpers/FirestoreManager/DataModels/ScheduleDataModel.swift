//
//  ScheduleDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import RxDataSources
import FirebaseFirestore

/// Firestore의 schedules 컬렉션 데이터 모델
struct ScheduleDataModel: FirestoreModelProtocol, IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Identity {
        return self.date.hashValue
    }
    
    let id: String
    let title: String
    let coupleId: String
    let date: Date
    let createdBy: String
    
    static func == (lhs: ScheduleDataModel, rhs: ScheduleDataModel) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    func transform() -> [String : Any] {
        return [
            "title": self.title,
            "coupleId": self.coupleId,
            "date": Timestamp(date: self.date),
            "createdBy": self.createdBy
        ]
    }
}
