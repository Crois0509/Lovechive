//
//  FirestoreManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import Firebase

/// Firestore의 CRUD 메소드를 관리하는 객체
final class FirestoreManager {
    
    private let db = Firestore.firestore() // Firestore Database
    
    static let shared = FirestoreManager()
    private init() {}
    
    /// Firestore에 저장/업데이트를 실행하는 메소드
    /// - Parameters:
    ///   - data: 저장/업데이트 할 데이터
    ///   - type: 저장할 데이터 타입
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
    
    /// Firestore에서 데이터를 불러오는 메소드
    /// - Parameters:
    ///   - type: 불러올 데이터 타입
    ///   - completion: 불러온 데이터를 처리할 closure
    func readFromFirestore(type: FirestoreDataTypes, _ completion: @escaping ([QueryDocumentSnapshot]?) -> Void) {
        switch type {
        case .user:
            guard let userId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.userId) else { return }
            let collection = db.collection(type.typeName)
            
            collection.getDocuments { querySnapshot, error in
                if let error = error {
                    debugPrint("❌ 데이터 가져오기 실패: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    debugPrint("❌ 문서가 없음")
                    return
                }

                // 📌 문서 ID를 기준으로 필터링
                let filteredDocuments = documents.filter { $0.documentID.contains(userId) }

                if filteredDocuments.isEmpty {
                    debugPrint("❌ 해당하는 문서를 찾을 수 없음")
                } else {
                    debugPrint("✅ 필터링된 문서 수:", filteredDocuments.count)
                    completion(filteredDocuments)
                }
            }
            
        case .couple:
            guard let coupleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId) else { return }
            let collection = db.collection(type.typeName)
            
            collection.getDocuments { querySnapshot, error in
                if let error = error {
                    debugPrint("❌ 데이터 가져오기 실패: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    debugPrint("❌ 문서가 없음")
                    return
                }

                // 📌 문서 ID를 기준으로 필터링
                let filteredDocuments = documents.filter { $0.documentID.contains(coupleId) }

                if filteredDocuments.isEmpty {
                    debugPrint("❌ 해당하는 문서를 찾을 수 없음")
                } else {
                    debugPrint("✅ 필터링된 문서 수:", filteredDocuments.count)
                    completion(filteredDocuments)
                }
            }
            
        case .diary:
            guard let coupleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId) else { return }
            let collection = db.collection(type.typeName)
            
            collection.whereField(AppConfig.UserDefaultsConfig.coupleId, isEqualTo: coupleId)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        debugPrint(error.localizedDescription, "❌ 데이터 읽기 실패")
                        completion(nil)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        debugPrint("❌ 데이터가 없습니다.")
                        completion(nil)
                        return
                    }
                    
                    debugPrint("✅ 데이터 불러오기 성공, 불러온 데이터 수:", documents.count)
                    completion(documents)
                }
            
        case .schedule:
            guard let coupleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId) else { return }
            let collection = db.collection(type.typeName)
            
            collection.whereField(AppConfig.UserDefaultsConfig.coupleId, isEqualTo: coupleId)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        debugPrint(error.localizedDescription, "❌ 데이터 읽기 실패")
                        completion(nil)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        debugPrint("❌ 데이터가 없습니다.")
                        completion(nil)
                        return
                    }
                    
                    debugPrint("✅ 데이터 불러오기 성공, 불러온 데이터 수:", documents.count)
                    completion(documents)
                }
        }
    }
    
    /// Firestore의 데이터를 삭제하는 메소드
    /// - Parameter type: 삭제할 데이터 타입
    func deleteFromFirestore(type: FirestoreDataTypes) {
        switch type {
        case .user:
            let userId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.userId) ?? ""
            let collection = db.collection(type.typeName).document(userId)
            
            collection.delete { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 삭제 실패")
                } else {
                    debugPrint("✅ 데이터 삭제 성공")
                }
            }
            
        case .couple:
            let coupleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.coupleId) ?? ""
            let collection = db.collection(type.typeName).document(coupleId)
            
            collection.delete { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 삭제 실패")
                } else {
                    debugPrint("✅ 데이터 삭제 성공")
                }
            }
            
        case .diary:
            let diaryId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.diaryId) ?? ""
            let collection = db.collection(type.typeName).document(diaryId)
            
            collection.delete { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 삭제 실패")
                } else {
                    debugPrint("✅ 데이터 삭제 성공")
                }
            }
            
        case .schedule:
            let scheduleId = UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.scheduleId) ?? ""
            let collection = db.collection(type.typeName).document(scheduleId)
            
            collection.delete { error in
                if let error {
                    debugPrint(error.localizedDescription, "❌ 데이터 삭제 실패")
                } else {
                    debugPrint("✅ 데이터 삭제 성공")
                }
            }

        }
    }
}
