//
//  DiaryDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import RxDataSources
import FirebaseFirestore

/// Firestore의 diaries 컬렉션 데이터 모델
struct DiaryDataModel: FirestoreModelProtocol, IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return self.id
    }
    
    let id: String
    let title: String
    let content: String
    let image: String
    let createdAt: Date
    let createdBy: String
    
    static func == (lhs: DiaryDataModel, rhs: DiaryDataModel) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    func transform() -> [String : Any] {
        return [
            AppConfig.DiariesModel.id: self.id,
            AppConfig.DiariesModel.title: self.title,
            AppConfig.DiariesModel.content: self.content,
            AppConfig.DiariesModel.image: self.image,
            AppConfig.DiariesModel.createdAt: Timestamp(date: self.createdAt),
            AppConfig.DiariesModel.createdBy: self.createdBy
        ]
    }
}
