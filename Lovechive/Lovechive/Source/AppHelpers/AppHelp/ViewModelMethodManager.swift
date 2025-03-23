//
//  ViewModelMethodManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/18/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseFirestore

class ViewModelMethodManager: AnyObject {
    
    /// 커스텀 Alert 뷰를 호출하는 메소드
    /// - Parameter type: 호출할 Alert의 타입
    /// - Returns: 데이터 저장 성공 여부를 담은 옵저버블
    func showAlertView(type: AlertTypes) -> PublishRelay<Bool> {
        guard let vc = AppHelpers.getTopViewController(),
              vc.children.last as? LovechiveAlertViewController == nil
        else { return .init() }
        
        let alert = LovechiveAlertViewController(type: type)
        
        vc.addChild(alert)
        vc.view.addSubview(alert.view)
        alert.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alert.didMove(toParent: vc)
        
        return alert.rx.dataSavedRelay
    }
    
    /// 커스텀 Alert 뷰를 dismiss 시키는 메소드
    func dismissAlertView() {
        guard let topView = AppHelpers.getTopViewController(),
              let alert = topView.children.last as? LovechiveAlertViewController
        else { return }
        
        alert.dismissSelf {
            alert.view.snp.removeConstraints()
            alert.view.removeFromSuperview()
            alert.removeFromParent()
        }
    }
    
    /// 키보드의 유무에 따라 커스텀 Alert 뷰의 위치를 변화 시키는 메소드
    /// - Parameter isTure: 키보드의 존재 유무
    func showKeyboard(_ isTure: Bool) {
        guard let topView = AppHelpers.getTopViewController() as? MainViewController,
              let alert = topView.children.last as? LovechiveAlertViewController
        else { return }
        
        let alertY = alert.alertView.frame.origin.y
        let centerY = alert.view.frame.midY
        let alertSize = alert.alertView.bounds.height / 2
        
        if isTure && (alertY + alertSize) >= centerY {
            alert.alertView.frame.origin.y -= 100
        } else if !isTure {
            alert.alertView.frame.origin.y = (centerY - alertSize)
        }
    }
    
    /// Firestore에서 데이터를 불러오는 메소드
    /// - Parameter type: 불러올 데이터 타입
    /// - Returns: 불러온 데이터 파일의 스냅샷 배열
    func fetchData(_ type: FirestoreDataTypes) -> Single<[QueryDocumentSnapshot]> {
        FirestoreManager.shared.readFromFirestore(type: type)
    }
    
    func fetchDiaryData(_ id: String) -> Single<[QueryDocumentSnapshot]> {
        FirestoreManager.shared.fetchDiaries(id)
    }
    
    /// FirestoreModelProtocol 데이터를 Firestore에 저장하는 메소드
    /// - Parameter data: 저장할 FirestoreModelProtocol 타입 데이터
    /// - Returns: 데이터 저장 성공 여부를 담은 옵저버블
    func saveData(_ data: [FirestoreModelProtocol], _ type: AlertTypes) -> Single<Bool> {
        switch type {
        case .newSchedule, .editSchedule:
            guard let scheduleData = data.first as? ScheduleDataModel else { return .error(NSError(domain: "❌ 타입 변환 실패", code: 0)) }
            
            return FirestoreManager.shared.saveToFirestore(scheduleData, type: .schedule(id: scheduleData.id))
            
        case .newDiary, .editDiary:
            guard let diaryData = data.first as? DiaryListDataModel else { return .error(NSError(domain: "❌ 타입 변환 실패", code: 0)) }
            
            return FirestoreManager.shared.saveToFirestore(diaryData, type: .diary(id: diaryData.diaryId))
                        
        case .editMyPage:
            guard let userData = data.first as? UserDataModel,
                  let coupleData = data.last as? CoupleDataModel
            else { return .error(NSError(domain: "❌ 타입 변환 실패", code: 0)) }
            
            let saveUser = FirestoreManager.shared.saveToFirestore(userData, type: .user)
            let saveCouple = FirestoreManager.shared.saveToFirestore(coupleData, type: .couple)
            
            return Single.zip(saveUser, saveCouple).map { $0.0 && $0.1 }
            
        }
    }
    
}
