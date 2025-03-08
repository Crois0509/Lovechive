//
//  DiaryDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

struct DiaryDataModel: FirestoreModelProtocol {
    let author: String
    let coupleId: String
    let content: String
    let createdAt: Date
    
    func transform() -> [String : Any] {
        return [
            "author": self.author,
            "coupleId": self.coupleId,
            "content": self.content,
            "createdAt": self.createdAt
        ]
    }
}
