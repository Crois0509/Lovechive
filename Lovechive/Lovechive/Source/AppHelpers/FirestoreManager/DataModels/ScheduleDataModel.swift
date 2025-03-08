//
//  ScheduleDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

struct ScheduleDataModel: FirestoreModelProtocol {
    let title: String
    let coupleId: String
    let date: Date
    let createdBy: String
    
    func transform() -> [String : Any] {
        return [
            "title": self.title,
            "coupleId": self.coupleId,
            "date": self.date,
            "createdBy": self.createdBy
        ]
    }
}
