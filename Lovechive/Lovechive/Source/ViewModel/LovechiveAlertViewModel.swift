//
//  LovechiveAlertViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

final class LovechiveAlertViewModel: ViewModelType {
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let activeButtonTapped: ControlEvent<Void>
        let firstSectionRelay: BehaviorRelay<String>
        let secondSectionRelay: BehaviorRelay<String>
        let thirdSectionRelay: BehaviorRelay<String>
    }
    
    struct Output {
        let dataSaved: PublishRelay<Bool>
    }
    
    private var firstSectionData: String = ""
    private var secondSectionData: String = ""
    private var thirdSectionData: String = ""
    
    private var disposeBag = DisposeBag()
    private let umd = UserDefaultsManager()
    private let alert = AlertManager.init(title: "경고", message: "모든 내용을 입력해 주세요!!", cancelTitle: "확인")
    
    private var alertType: AlertTypes
    
    private let dataSaved = PublishRelay<Bool>()
    
    init(type: AlertTypes) {
        alertType = type
    }
    
    func transform(input: Input) -> Output {
        
        input.cancelButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.dismissAlertView()
            }
            .disposed(by: disposeBag)
        
        input.activeButtonTapped
            .withUnretained(self)
            .flatMapLatest { owner, _ -> Observable<[FirestoreModelProtocol]> in
                let isEmpty = owner.checkEmpty()
                
                if isEmpty {
                    return owner.alert.showAlert(.alert).map { _ in [] }.asObservable()
                } else {
                    return .just(owner.mappingData())
                }
            }
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] data -> Single<Bool> in
                guard let self else { return .just(false) }
                return self.saveData(data)
            }
            .asDriver(onErrorJustReturn: false)
            .drive { [weak self] isSuccess in
                self?.dataSaved.accept(isSuccess)
                self?.dismissAlertView()
            }
            .disposed(by: disposeBag)
        
        input.firstSectionRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, text in
                owner.firstSectionData = text
            }
            .disposed(by: disposeBag)
        
        input.secondSectionRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, text in
                owner.secondSectionData = text
            }
            .disposed(by: disposeBag)
        
        input.thirdSectionRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, text in
                owner.thirdSectionData = text
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .distinctUntilChanged()
            .map { _ in true }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, isShow in
                owner.showKeyboard(isShow)
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .distinctUntilChanged()
            .map { _ in false }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, isHide in
                owner.showKeyboard(isHide)
            }
            .disposed(by: disposeBag)
        
        return Output(dataSaved: dataSaved)
    }
}

private extension LovechiveAlertViewModel {
    
    func dismissAlertView() {
        guard let topView = AppHelpers.getTopViewController() as? MainViewController,
              let alert = topView.children.last as? LovechiveAlertViewController
        else { return }
        
        alert.dismissSelf {
            alert.view.snp.removeConstraints()
            alert.view.removeFromSuperview()
            alert.removeFromParent()
        }
    }
    
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
            alert.alertView.frame.origin.y = (alertY + alertSize)
        }
    }
    
    func checkEmpty() -> Bool {
        switch alertType {
        case .newSchedule, .editSchedule:
            return firstSectionData.isEmpty || secondSectionData.isEmpty
            
        default:
            return firstSectionData.isEmpty || secondSectionData.isEmpty || thirdSectionData.isEmpty
        }
    }
    
    func mappingData() -> [FirestoreModelProtocol] {
        switch alertType {
        case .newSchedule(date: let date):
            let scheduleDate = date.formattedDateToString(.yearMonthDay) + " " + firstSectionData
            
            let schedule = ScheduleDataModel(id: UUID().uuidString,
                                             title: secondSectionData,
                                             coupleId: umd.coupleId,
                                             date: scheduleDate.formattedStringToDate(.fullTime),
                                             createdBy: umd.userId)
            
            return [schedule]
            
        case .editSchedule(data: let data):
            let scheduleDate = data.date.formattedDateToString(.yearMonthDay) + " " + firstSectionData
            
            let schedule = ScheduleDataModel(id: data.id,
                                             title: secondSectionData,
                                             coupleId: data.coupleId,
                                             date: scheduleDate.formattedStringToDate(.fullTime),
                                             createdBy: data.createdBy)
            
            return [schedule]
            
        case .editMyPage(user: let user, couple: let couple):
            let userData = UserDataModel(id: user.id,
                                         name: firstSectionData,
                                         email: user.email,
                                         coupleId: user.coupleId,
                                         birthDay: secondSectionData.formattedStringToDate(.yearMonthDay),
                                         createdAt: user.createdAt)
            
            let user1Name = couple.user1Id == user.id ? firstSectionData : couple.user1Name
            let user2Name = couple.user2Id == user.id ? firstSectionData : couple.user2Name
            
            let coupleData = CoupleDataModel(user1Id: couple.user1Id,
                                             user2Id: couple.user2Id,
                                             user1Name: user1Name,
                                             user2Name: user2Name,
                                             dDay: thirdSectionData.formattedStringToDate(.yearMonthDay))
            
            return [userData, coupleData]
            
        case .newDiary, .editDiary: return []
            
        }
    }
    
    func saveData(_ data: [FirestoreModelProtocol]) -> Single<Bool> {
        switch alertType {
        case .newSchedule, .editSchedule:
            guard let scheduleData = data.first as? ScheduleDataModel else { return .error(NSError(domain: "타입 변환 실패", code: 0)) }
            
            return FirestoreManager.shared.saveToFirestore(scheduleData, type: .schedule(id: scheduleData.id))
            
        case .newDiary, .editDiary: return .just(false)
            
        case .editMyPage:
            guard let userData = data.first as? UserDataModel,
                  let coupleData = data.last as? CoupleDataModel
            else { return .error(NSError(domain: "타입 변환 실패", code: 0)) }
            
            let saveUser = FirestoreManager.shared.saveToFirestore(userData, type: .user)
            let saveCouple = FirestoreManager.shared.saveToFirestore(coupleData, type: .couple)
            
            return Single.zip(saveUser, saveCouple).map { $0.0 && $0.1 }
            
        }
    }
}
