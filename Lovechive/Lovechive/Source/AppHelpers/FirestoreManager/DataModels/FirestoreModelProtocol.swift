//
//  FirestoreModelProtocol.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

/// Firestore 데이터 모델 공용 프로토콜
protocol FirestoreModelProtocol {
    func transform() -> [String: Any]
}
