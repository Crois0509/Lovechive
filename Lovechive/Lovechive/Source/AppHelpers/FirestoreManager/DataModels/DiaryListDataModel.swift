//
//  DiaryListDataModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import Foundation
import RxDataSources
import FirebaseFirestore

/// Firestore의 diaries 컬렉션 데이터 모델
struct DiaryListDataModel: FirestoreModelProtocol, IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: Identity {
        return self.diaryId
    }
    
    let coupleId: String
    let diaryId: String
    let diaryTitle: String
    let diarySubTitle: String
    let diaryColor: String
    let diaryCreatedAt: Date
    
    static func == (lhs: DiaryListDataModel, rhs: DiaryListDataModel) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    func transform() -> [String : Any] {
        return [
            AppConfig.DiariesModel.coupleId: self.coupleId,
            AppConfig.DiariesModel.diaryId: self.diaryId,
            AppConfig.DiariesModel.diaryTitle: self.diaryTitle,
            AppConfig.DiariesModel.diarySubTitle: self.diarySubTitle,
            AppConfig.DiariesModel.diaryColor: self.diaryColor,
            AppConfig.DiariesModel.diaryCreatedAt: self.diaryCreatedAt
        ]
    }
}

