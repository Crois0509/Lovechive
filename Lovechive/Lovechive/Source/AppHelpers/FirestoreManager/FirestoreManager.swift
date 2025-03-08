//
//  FirestoreManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import Firebase

final class FirestoreManager {
    
    private let db = Firestore.firestore()
    
    static let shared = FirestoreManager()
    private init() {}
    
    func saveToFirestore(_ data: FirestoreModelProtocol, type: FirestoreDataTypes) {
        switch type {
        case .user:
            let userId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.userId) ?? ""
            let collection = db.collection(type.typeName).document(userId)
            
            collection.setData(data.transform()) { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 저장 실패")
                } else {
                    debugPrint("✅ 데이터 저장 성공", data.transform().values)
                }
            }
        case .couple:
            let coupleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId) ?? ""
            let collection = db.collection(type.typeName).document(coupleId)
            
            collection.setData(data.transform()) { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 저장 실패")
                } else {
                    debugPrint("✅ 데이터 저장 성공", data.transform().values)
                }
            }
        case .diary:
            let diaryId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.diaryId) ?? ""
            let collection = db.collection(type.typeName).document(diaryId)
            
            collection.setData(data.transform()) { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 저장 실패")
                } else {
                    debugPrint("✅ 데이터 저장 성공", data.transform().values)
                }
            }
        case .schedule:
            let scheduleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.scheduleId) ?? ""
            let collection = db.collection(type.typeName).document(scheduleId)
            
            collection.setData(data.transform()) { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 저장 실패")
                } else {
                    debugPrint("✅ 데이터 저장 성공", data.transform().values)
                }
            }
        }
    }
    
}
