//
//  FirestoreManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/8/25.
//

import Foundation
import Firebase
import RxSwift

/// Firestore의 CRUD 메소드를 관리하는 객체
final class FirestoreManager {
    
    private let db = Firestore.firestore() // Firestore Database
    private let udm = UserDefaultsManager()
    
    static let shared = FirestoreManager()
    private init() {}
    
    /// Firestore에 저장/업데이트를 실행하는 메소드
    /// - Parameters:
    ///   - data: 저장/업데이트 할 데이터
    ///   - type: 저장할 데이터 타입
    func saveToFirestore(_ data: FirestoreModelProtocol, type: FirestoreDataTypes) -> Single<Void> {
        return Single.create { single in
            let collectionRef = self.db.collection(type.typeName)
            var documentRef: DocumentReference
            
            switch type {
            case .user:
                let userId = self.udm.userId
                documentRef = collectionRef.document(userId)
                
            case .couple:
                let coupleId = self.udm.coupleId
                documentRef = collectionRef.document(coupleId)
                
            case .diary(id: let id):
                if !id.isEmpty {
                    documentRef = collectionRef.document(id)
                } else {
                    documentRef = collectionRef.document()
                }
                
            case .schedule(id: let id):
                if !id.isEmpty {
                    documentRef = collectionRef.document(id)
                } else {
                    documentRef = collectionRef.document()
                }
            }
            
            documentRef.setData(data.transform()) { error in
                if let error {
                    debugPrint("❌ \(type.typeName) 데이터 저장 실패: \(error.localizedDescription)")
                    single(.failure(error))
                } else {
                    debugPrint("✅ \(type.typeName) 데이터 저장 성공: \(data.transform().values)")
                    single(.success(()))
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Firestore에서 데이터를 불러오는 메소드
    /// - Parameters:
    ///   - type: 불러올 데이터 타입
    ///   - completion: 불러온 데이터를 처리할 closure
    func readFromFirestore(type: FirestoreDataTypes) -> Single<[QueryDocumentSnapshot]> {
        return Single.create { single in
            let collectionRef = self.db.collection(type.typeName)
            var query: Query = collectionRef
            
            switch type {
            case .user:
                let userId = self.udm.userId
                query = collectionRef.whereField(FieldPath.documentID(), isEqualTo: userId)
                
            case .couple:
                let coupleId = self.udm.coupleId
                query = collectionRef.whereField(FieldPath.documentID(), isEqualTo: coupleId)
                
            case .diary, .schedule:
                let coupleId = self.udm.coupleId
                query = collectionRef.whereField(AppConfig.UserDefaultsConfig.coupleId, isEqualTo: coupleId)
            }
            
            query.getDocuments { querySnapshot, error in
                if let error {
                    debugPrint("❌ \(type.typeName) 데이터 불러오기 실패: \(error.localizedDescription)")
                    single(.failure(error))
                    
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    debugPrint("✅ \(type.typeName) 데이터 불러오기 성공")
                    single(.success(documents))
                    
                } else {
                    debugPrint("❌ \(type.typeName) 문서 없음")
                    single(.success([]))
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Firestore의 데이터를 삭제하는 메소드
    /// - Parameter type: 삭제할 데이터 타입
    func deleteFromFirestore(type: FirestoreDataTypes) -> Single<Void> {
        return Single.create { single in
            let collectionRef = self.db.collection(type.typeName)
            var documentRef: DocumentReference
            
            switch type {
            case .user:
                let userId = self.udm.userId
                documentRef = collectionRef.document(userId)
                
            case .couple:
                let coupleId = self.udm.coupleId
                documentRef = collectionRef.document(coupleId)
                
            case .diary(id: let id):
                if !id.isEmpty {
                    documentRef = collectionRef.document(id)
                } else {
                    documentRef = collectionRef.document()
                }
                
            case .schedule(id: let id):
                if !id.isEmpty {
                    documentRef = collectionRef.document(id)
                } else {
                    documentRef = collectionRef.document()
                }
            }
            
            documentRef.delete { error in
                if let error {
                    debugPrint("❌ \(type.typeName) 데이터 삭제 실패: \(error.localizedDescription)")
                    single(.failure(error))
                } else {
                    debugPrint("✅ \(type.typeName) 데이터 삭제 성공")
                    single(.success(()))
                }
            }
            
            return Disposables.create()
        }
    }
}
