//
//  LovechiveFirebaseTests.swift
//  LovechiveTests
//
//  Created by 장상경 on 3/7/25.
//

import XCTest
import Firebase

final class LovechiveFirebaseTests: XCTestCase {

    override func setUpWithError() throws {
        super.setUp()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    override func tearDownWithError() throws {
        super.tearDown()
            Firestore.firestore().terminate { error in
                if let error = error {
                    print("🔥 Firestore 종료 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("✅ Firestore 정상 종료")
                }
            }
    }
    
    // Firestore 쓰기 테스트
    func testWriteFirestore() {
        // given: Firestore 인스턴스와 테스트할 데이터 준비
        let db = Firestore.firestore()
        let testDocRef = db.collection("testCollection").document("testDocument")
        let testData: [String: Any] = [
            "name": "Lovechive Test",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        let expectation = self.expectation(description: "Firestore 데이터 쓰기 완료")
        
        // when: Firestore에 데이터 저장
        testDocRef.setData(testData) { error in
            // then: 저장이 성공했는지 검증
            XCTAssertNil(error, "Firestore 쓰기 실패: \(error?.localizedDescription ?? "unkowned error")")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    // Firestore 읽기 테스트
    func testReadFromFirestore() {
        // given: Firestore 인스턴스와 문서 참조
        let db = Firestore.firestore()
        let testDocRef = db.collection("testCollection").document("testDocument")
        
        let expectation = self.expectation(description: "Firestore 데이터 읽기 완료")
        
        // when: Firestore에서 문서를 가져옴
        testDocRef.getDocument { (document, error) in
            // then: 데이터를 제대로 가져왔는지 검증
            XCTAssertNil(error, "Firestore 읽기 실패: \(error?.localizedDescription ?? "unkowned error")")
            XCTAssertNotNil(document, "문서가 존재하지 않음")
            XCTAssertEqual(document?.data()?["name"] as? String, "Lovechive Test", "데이터 불일치")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    // Firestore 삭제 테스트
    func testDeleteFromFirestore() {
        // given: Firestore 인스턴스와 문서 참조
        let db = Firestore.firestore()
        let testDocRef = db.collection("testCollection").document("testDocument")
        
        let expectation = self.expectation(description: "Firestore 데이터 삭제 완료")
        
        // when: Firestore에서 문서 삭제
        testDocRef.delete { error in
            // then: 삭제가 성공했는지 검증
            XCTAssertNil(error, "Firestore 삭제 실패: \(error?.localizedDescription ?? "unkowned error")")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }

}
