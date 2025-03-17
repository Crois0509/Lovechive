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
    
    private var disposeBag = DisposeBag()
    private let umd = UserDefaultsManager()
    private let alert = AlertManager.init(title: "경고", message: "모든 내용을 입력해 주세요!!", cancelTitle: "확인")
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let activeButtonTapped: ControlEvent<Void>
        let scheduleTimeRelay: BehaviorRelay<String>
        let scheduleTitleRelay: BehaviorRelay<String>
    }
    
    struct Output {
        let dataSaved: PublishRelay<Void>
    }
    
    private var scheduleTime: String?
    private var scheduleTitle: String?
    private var selectedDate: String?
    private var dataId: String?
    
    private var isKeyboardVisible: Bool = false
    
    private let dataSaved = PublishRelay<Void>()
    
    init(type: AlertTypes) {
        switch type {
        case .newSchedule(date: let date):
            selectedDate = date.formattedDateToString(.yearMonthDay)
        case .editSchedule(data: let data):
            selectedDate = data.date.formattedDateToString(.yearMonthDay)
            dataId = data.id
        case .newDiary, .editDiary, .editMyPage: break
        }
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
            .compactMap { owner, _ -> ScheduleDataModel? in
                guard let title = owner.scheduleTitle, let date = owner.scheduleTime,
                      let selectDate = date.formattedStringToDate(),
                      !title.isEmpty
                else {
                    owner.alert.showAlert(.alert)
                    return nil
                }
                
                return owner.mappingScheduleData(title: title, date: selectDate)
            }
            .flatMap { [weak self] data -> Signal<Void> in
                guard let self else {
                    return .empty()
                }
                return self.saveScheduleData(data).asSignal(onErrorSignalWith: .empty())
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] _ in
                self?.dataSaved.accept(())
                self?.dismissAlertView()
            }
            .disposed(by: disposeBag)
        
        input.scheduleTimeRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, text in
                let selectDate = owner.selectedDate ?? ""
                let date = selectDate + " " + text
                owner.scheduleTime = date
            }
            .disposed(by: disposeBag)
        
        input.scheduleTitleRelay
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, text in
                owner.scheduleTitle = text
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, isShow in
                owner.showKeyboard(isShow)
            }
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ in false }
            .asSignal(onErrorSignalWith: .empty())
            .withUnretained(self)
            .emit { owner, isHide in
                owner.showKeyboard(isHide)
            }
            .disposed(by: disposeBag)
        
        return Output(dataSaved: dataSaved)
    }
    
    private func dismissAlertView() {
        guard let topView = AppHelpers.getTopViewController() as? MainViewController,
              let alert = topView.children.last as? LovechiveAlertViewController
        else { return }
        
        alert.dismissSelf {
            alert.view.snp.removeConstraints()
            alert.view.removeFromSuperview()
            alert.removeFromParent()
        }
    }
    
    private func showKeyboard(_ isTure: Bool) {
        guard let topView = AppHelpers.getTopViewController() as? MainViewController,
              let alert = topView.children.last as? LovechiveAlertViewController
        else { return }
        
        if isTure && (alert.alertView.frame.origin.y < 300) {
            alert.alertView.frame.origin.y = alert.alertView.frame.origin.y
        } else if isTure && (alert.alertView.frame.origin.y > 300) {
            alert.alertView.frame.origin.y -= 100
        } else if !isTure {
            alert.alertView.frame.origin.y += 100
        }
    }
    
    private func mappingScheduleData(title: String, date: Date) -> ScheduleDataModel {
        let id = dataId ?? UUID().uuidString
        return ScheduleDataModel(id: id, title: title, coupleId: umd.coupleId, date: date, createdBy: umd.userId)
    }
    
    private func saveScheduleData(_ data: ScheduleDataModel) -> Single<Void> {
        return FirestoreManager.shared.saveToFirestore(data, type: .schedule(id: data.id))
    }
}
