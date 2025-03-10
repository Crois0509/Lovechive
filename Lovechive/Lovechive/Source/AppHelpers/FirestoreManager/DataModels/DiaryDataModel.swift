//
//  DiaryDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import FirebaseFirestore

/// Firestore의 diaries 컬렉션 데이터 모델
struct DiaryDataModel: FirestoreModelProtocol {
    let id: String
    let author: String
    let coupleId: String
    let content: String
    let image: String
    let createdAt: Date
    
    func transform() -> [String : Any] {
        return [
            "author": self.author,
            "coupleId": self.coupleId,
            "content": self.content,
            "image": self.image,
            "createdAt": Timestamp(date: self.createdAt)
        ]
    }
}
