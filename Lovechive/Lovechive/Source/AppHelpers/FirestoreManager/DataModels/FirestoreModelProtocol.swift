//
//  FirestoreModelProtocol.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation

/// Firestore 데이터 모델 공용 프로토콜
protocol FirestoreModelProtocol {
    /// 모델 파일의 프로퍼티들을 Firestore에 저장할 데이터 타입으로 가공하는 메소드
    /// - Returns: Firestore 데이터 타입
    func transform() -> [String: Any]
}
