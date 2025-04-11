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
    
    func fetchDiaries(_ id: String) -> Single<[QueryDocumentSnapshot]> {
        return Single.create { single in
            let coupleDocumentRef = self.db.collection("diaries").document(id)
            
            coupleDocumentRef.collection("Diaries").addSnapshotListener { querySnapshot, error in
                if let error = error {
                    debugPrint("❌ Diary 데이터 불러오기 실패: \(error.localizedDescription)")
                    single(.failure(error))
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    debugPrint("❌ Diary 데이터 없음")
                    single(.success([]))  // 문서가 없으면 빈 배열 반환
                    return
                }
                
                debugPrint("✅ Diary 데이터 불러오기 성공, count: \(documents.count)")
                single(.success(documents))
            }
            
            return Disposables.create()
        }
    }
    
    func saveDiaries(_ data: DiaryDataModel, _ documentId: String, _ dataId: String) -> Single<Bool> {
        return Single.create { single in
            
            let collectionRef = self.db.collection("diaries").document(documentId).collection("Diaries")
            let documentRef: DocumentReference = collectionRef.document(dataId)
            
            documentRef.setData(data.transform()) { error in
                if let error {
                    debugPrint("❌ 다이어리 데이터 저장 실패: \(error.localizedDescription)")
                    single(.failure(error))
                } else {
                    debugPrint("✅ 다이어리 데이터 저장 성공: \(data.transform().values)")
                    single(.success(true))
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Firestore에 저장/업데이트를 실행하는 메소드
    /// - Parameters:
    ///   - data: 저장/업데이트 할 데이터
    ///   - type: 저장할 데이터 타입
    func saveToFirestore(_ data: FirestoreModelProtocol, type: FirestoreDataTypes) -> Single<Bool> {
        return Single.create { single in
            let collectionRef = self.db.collection(type.typeName)
            var documentRef: DocumentReference
            
            switch type {
            case .user:
                let userId = self.udm.userId
                documentRef = collectionRef.document(userId)
                
            case .couple(id: let id):
                let coupleId = self.udm.coupleId
                
                if let id {
                    documentRef = collectionRef.document(id)
                } else {
                    documentRef = collectionRef.document(coupleId)
                }
                
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
                    single(.success(true))
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
                
            case .couple(id: let id):
                let coupleId = self.udm.coupleId
                
                if let id {
                    query = collectionRef.whereField(FieldPath.documentID(), isEqualTo: id)
                } else {
                    query = collectionRef.whereField(FieldPath.documentID(), isEqualTo: coupleId)
                }
                
            case .diary:
                let coupleId = self.udm.coupleId
                query = collectionRef.whereField(AppConfig.UserDefaultsConfig.coupleId, isEqualTo: coupleId)
                
            case .schedule:
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
    
    func deletedDiaries(_ documentId: String, _ dataId: String?) -> Single<Bool> {
        return Single.create { single in
            
            let collectionRef = self.db.collection("diaries").document(documentId).collection("Diaries")
            var documentRef: DocumentReference
            
            if let dataId {
                documentRef = collectionRef.document(dataId)
            } else {
                documentRef = collectionRef.document()
            }
            
            documentRef.delete { error in
                if let error {
                    debugPrint("❌ 다이어리 데이터 삭제 실패: \(error.localizedDescription)")
                    single(.failure(error))
                } else {
                    debugPrint("✅ 다이어리 데이터 삭제 성공")
                    single(.success(true))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func deleteDiariesForCouple() -> Single<Bool> {
        let coupleId = self.udm.coupleId
        let diariesCollection = db.collection("diaries")
        
        return Single.create { single in
            // 1️⃣ coupleId와 동일한 문서를 조회
            diariesCollection.whereField("coupleId", isEqualTo: coupleId).getDocuments { (snapshot, error) in
                if let error = error {
                    print("🚨 문서 조회 실패: \(error.localizedDescription)")
                    single(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ 해당 coupleId에 대한 문서가 없음")
                    single(.success(false))
                    return
                }
                
                let dispatchGroup = DispatchGroup() // 비동기 작업 완료 여부를 추적
                
                for document in documents {
                    let documentRef = diariesCollection.document(document.documentID)
                    let diariesSubCollection = documentRef.collection("Diaries")
                    
                    dispatchGroup.enter()
                    
                    // 2️⃣ Diaries 서브 컬렉션 삭제
                    self.deleteCollection(collectionRef: diariesSubCollection) {
                        // 3️⃣ 부모 문서 삭제
                        documentRef.delete { error in
                            if let error = error {
                                print("🚨 문서 삭제 실패: \(error.localizedDescription)")
                            } else {
                                print("✅ 문서 삭제 완료: \(document.documentID)")
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    print("🎉 모든 데이터 삭제 완료")
                    single(.success(true))
                }
            }
            
            return Disposables.create()
        }
    }
    
    // 🔹 Firestore 컬렉션을 재귀적으로 삭제하는 함수
    func deleteCollection(collectionRef: CollectionReference, batchSize: Int = 10, completion: @escaping () -> Void) {
        collectionRef.limit(to: batchSize).getDocuments { (snapshot, error) in
            if let error = error {
                print("🚨 서브 컬렉션 조회 실패: \(error.localizedDescription)")
                completion()
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("✅ 서브 컬렉션 삭제 완료")
                completion()
                return
            }

            let batch = Firestore.firestore().batch()
            for document in documents {
                batch.deleteDocument(document.reference)
            }

            batch.commit { error in
                if let error = error {
                    print("🚨 서브 컬렉션 삭제 실패: \(error.localizedDescription)")
                    completion()
                    return
                }
                
                // 🔥 남아있는 데이터가 있으면 다시 삭제 요청
                self.deleteCollection(collectionRef: collectionRef, batchSize: batchSize, completion: completion)
            }
        }
    }
    
    /// Firestore의 데이터를 삭제하는 메소드
    /// - Parameter type: 삭제할 데이터 타입
    func deleteFromFirestore(type: FirestoreDataTypes) -> Single<Bool> {
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
                    single(.success(true))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func deleteAllDataFromFirestore(type: FirestoreDataTypes) -> Single<Bool> {
        return Single.create { single in
            let coupleId = self.udm.coupleId
            let userId = self.udm.userId
            var query: Query = self.db.collection(type.typeName) // ✅ Query 타입으로 변경

            // ✅ Firestore 필터링 적용
            switch type {
            case .user:
                query = query.whereField(AppConfig.UserModel.id, isEqualTo: userId)
            case .couple:
                query = query.whereField(FieldPath.documentID(), isEqualTo: coupleId)
            case .diary:
                query = query.whereField(AppConfig.DiariesModel.coupleId, isEqualTo: coupleId)
            case .schedule:
                query = query.whereField(AppConfig.SchedulesModel.coupleId, isEqualTo: coupleId)
            }

            // ✅ Firestore에서 문서 조회 및 삭제
            query.getDocuments { snapshot, error in
                if let error = error {
                    debugPrint("🚨 문서 조회 실패: \(error.localizedDescription)")
                    single(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    debugPrint("⚠️ 해당 \(type.typeName)에 대한 문서가 없음")
                    single(.success(false)) // 문서 없음 → 정상적인 상태 처리
                    return
                }

                let dispatchGroup = DispatchGroup()
                var deleteError: Error?

                for document in documents {
                    dispatchGroup.enter()
                    document.reference.delete { error in
                        if let error {
                            debugPrint("❌ \(type.typeName) 데이터 삭제 실패: \(error.localizedDescription)")
                            deleteError = error
                        } else {
                            debugPrint("✅ \(type.typeName) 데이터 삭제 성공")
                        }
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    if let error = deleteError {
                        single(.failure(error))
                    } else {
                        single(.success(true))
                    }
                }
            }

            return Disposables.create()
        }
    }
    
    func deleteAllCoupleData() -> Single<Bool> {
        let manager = FirestoreManager.shared
        
        return manager.deleteAllDataFromFirestore(type: .schedule(id: ""))
            .flatMap { _ in
                return manager.deleteDiariesForCouple()
            }
            .flatMap { _ in
                return manager.deleteFromFirestore(type: .couple(id: nil))
            }
    }
    
    func readFromFirestoreInCoupleData() async throws -> [QueryDocumentSnapshot] {
        let collectionRef = self.db.collection("couples")
        let snapshot = try await collectionRef.whereField(FieldPath.documentID(), isEqualTo: self.udm.coupleId).getDocuments()
        
        return snapshot.documents
    }
}
 
