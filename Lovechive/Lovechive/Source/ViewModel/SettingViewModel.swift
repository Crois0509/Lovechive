//
//  SettingViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/17/25.
//

import UIKit
import FirebaseFirestore
import RxSwift
import RxCocoa

/// 설정 뷰 뷰 모델
final class SettingViewModel: ViewModelMethodManager, ViewModelType {
    
    // MARK: - Input & Output Type
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let editButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let sections: BehaviorRelay<[SetTableSection]>
        let myPageDataRelay: Observable<MyPageDataModel>
    }
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    
    private var alert = AlertManager(title: "경고", message: "", cancelTitle: "취소", destructiveTitle: "확인")
    private var alarmAlert = AlertManager(title: "알림", message: "", cancelTitle: "취소", activeTitle: "확인")
    private let guestModeAlert = AlertManager(title: "알림", message: "이 기능은 로그인 후 사용할 수 있습니다.\n로그인 하시겠습니까?", cancelTitle: "취소", activeTitle: "확인")
    
    private lazy var sections = BehaviorRelay<[SetTableSection]>(value: [])
    private let userDataRelay = BehaviorRelay<[UserDataModel]>(value: [])
    private let coupleDataRelay = BehaviorRelay<[CoupleDataModel]>(value: [])
    
    private var myPageDataRelay: Observable<MyPageDataModel> {
        return Observable
            .combineLatest(userDataRelay, coupleDataRelay)
            .compactMap { user, couple -> MyPageDataModel? in
                guard let userData = user.first, let coupleData = couple.first else { return nil }
                let lover = userData.name == coupleData.user1Name ? coupleData.user2Name : coupleData.user1Name
                
                return MyPageDataModel(name: userData.name, lover: lover, birthDay: userData.birthDay, anniversary: coupleData.dDay)
            }
            .asObservable()
    }
    
    /// input을 output으로 변환하는 메소드
    /// - Parameter input: input 데이터
    /// - Returns: output 데이터
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .take(1)
            .withUnretained(self)
            .map { owner, _ in
                SetTableSection(items: owner.defaultSettingModels)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] section in
                self?.sections.accept([section])
            }
            .disposed(by: disposeBag)
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.fetchData(.user)
            }
            .compactMap { [weak self] query in
                self?.mappingUserData(query)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] data in
                self?.userDataRelay.accept([data])
            }
            .disposed(by: disposeBag)
        
        userDataRelay
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.fetchData(.couple)
            }
            .compactMap { [weak self] query in
                self?.mappingCoupleData(query)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] data in
                self?.coupleDataRelay.accept([data])
            }
            .disposed(by: disposeBag)
        
        input.editButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ -> PublishRelay<Bool> in
                guard let user = owner.userDataRelay.value.first,
                      let couple = owner.coupleDataRelay.value.first
                else { return .init() }
                
                return owner.showAlertView(type: .editMyPage(user: user, couple: couple))
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { isSuccess in
                if isSuccess {
                    input.fetchTrigger.accept(())
                } else {
                    debugPrint("❌ 내 정보 편집 실패")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(sections: sections,
                      myPageDataRelay: myPageDataRelay
        )
    }
    
    func transformToGuestMode(input: Input) -> Output {
        
        input.editButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.guestModeAlert.showAlert(.alert)
            }
            .asSignal(onErrorJustReturn: false)
            .emit { isConfirm in
                if isConfirm {
                    UserDefaultsManager().saveToUserDefaults(false, forKey: AppConfig.UserDefaultsConfig.guestMode)
                    AppHelpers.changeRootViewControllerFromWindow(.login)
                } else {
                    debugPrint("로그인 취소")
                }
            }
            .disposed(by: disposeBag)
        
        input.fetchTrigger
            .take(1)
            .withUnretained(self)
            .map { owner, _ in
                SetTableSection(items: owner.defaultSettingModels)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] section in
                self?.sections.accept([section])
            }
            .disposed(by: disposeBag)
        
        return Output(sections: sections,
                      myPageDataRelay: myPageDataRelay
        )
    }
}

// MARK: - ViewModel Private Method

private extension SettingViewModel {
    
    /// 스냅샷 데이터를 UserDataModel 타입으로 변환하는 메소드
    /// - Parameter query: 스냅샷 데이터
    /// - Returns: 변환된 UserDataModel 데이터
    func mappingUserData(_ query: [QueryDocumentSnapshot]) -> UserDataModel? {
        guard let user = query.first else { return nil }
        
        return UserDataModel(id: user.data()[AppConfig.UserModel.id] as? String ?? "",
                             name: user.data()[AppConfig.UserModel.name] as? String ?? "",
                             email: user.data()[AppConfig.UserModel.email] as? String ?? "",
                             coupleId: user.data()[AppConfig.UserModel.coupleId] as? String ?? "",
                             birthDay: (user.data()[AppConfig.UserModel.birthDay] as? Timestamp)?.dateValue() ?? Date(),
                             createdAt: (user.data()[AppConfig.UserModel.createdAt] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    /// 스냅샷 데이터를 CoupleDataModel 타입으로 변환하는 메소드
    /// - Parameter query: 스냅샷 데이터
    /// - Returns: 변환된 CoupleDataModel 데이터
    func mappingCoupleData(_ query: [QueryDocumentSnapshot]) -> CoupleDataModel? {
        guard let couple = query.first else { return nil }
        
        return CoupleDataModel(user1Id: couple.data()[AppConfig.CouplesModel.user1Id] as? String ?? "",
                               user2Id: couple.data()[AppConfig.CouplesModel.user2Id] as? String ?? "",
                               user1Name: couple.data()[AppConfig.CouplesModel.user1Name] as? String ?? "",
                               user2Name: couple.data()[AppConfig.CouplesModel.user2Name] as? String ?? "",
                               dDay: (couple.data()[AppConfig.CouplesModel.dDay] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}

// MARK: - SettingTableCellModel

private extension SettingViewModel {
    
    // 설정탭에 넣을 셀을 정의하는 프로퍼티
    var defaultSettingModels: [SettingTableCellModel] {
        return [
            SettingTableCellModel(
                title: AppConfig.SettingConfig.alarm,
                extraView: setupSwitch(),
                action: toggleNotificationSetting
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.privacy,
                extraView: setupLabel(">"),
                action: pushURLPage(.privacyInfo)
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.playInfo,
                extraView: setupLabel(">"),
                action: pushURLPage(.playInfo)
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.review,
                extraView: setupLabel(">"),
                action: pushURLPage(.review)
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.bug,
                extraView: setupLabel(">"),
                action: pushURLPage(.bug)
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.versionInfo,
                extraView: setupLabel(AppConfig.SettingConfig.version),
                action: nil
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.membershipWithdrawal,
                extraView: nil,
                action: showDestructiveAlert
            ),
            
            SettingTableCellModel(
                title: AppConfig.SettingConfig.signOut,
                extraView: nil,
                action: showSignoutAlert
            )
        ]
    }
    
    /// UILabel을 설정하는 메소드
    /// - Parameter text: Label Text
    /// - Returns: UILabel
    func setupLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .myoyaFont(24)
        label.textColor = .Personal.highlightPink
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }
    
    /// 토글 스위치를 구현하는 메소드
    /// - Returns: UISwitch
    func setupSwitch() -> UISwitch {
        let toggleSwitch = UISwitch()
        
        NotificationPermissionCheck.check { isOn in
            DispatchQueue.main.async {
                toggleSwitch.isOn = isOn
            }
        }
        
        toggleSwitch.thumbTintColor = .white
        toggleSwitch.onTintColor = .Personal.highlightPink
        
        return toggleSwitch
    }
    
    func showSignoutAlert() {
        alert.message = "정말 로그아웃 하시겠습니까?"
        
        alert.showAlert(.alert)
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, isConfirm in
                if isConfirm {
                    UserDefaultsManager().saveToUserDefaults(false, forKey: AppConfig.UserDefaultsConfig.login)
                    UserDefaultsManager().saveToUserDefaults(false, forKey: AppConfig.UserDefaultsConfig.guestMode)
                    AppHelpers.changeRootViewControllerFromWindow(.login)
                } else {
                    debugPrint("로그아웃 취소")
                }
            }
            .disposed(by: disposeBag)
    }
    
    func showDestructiveAlert() {
        let isGuestMode = UserDefaults.standard.bool(forKey: AppConfig.UserDefaultsConfig.guestMode)
        alert.message = isGuestMode ? "회원가입을 위해\n로그인 화면으로 돌아가시겠습니까?" : "회원 정보는 복구되지 않습니다.\n정말 회원 탈퇴를 진행하시겠습니까?"
        
        alert.showAlert(.alert)
            .flatMap { isConfirm in
                if isConfirm && !isGuestMode {
                    return FirestoreManager.shared.deleteFromFirestore(type: .user)
                } else {
                    return .just(isConfirm)
                }
            }
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, isConfirm in
                if isConfirm {
                    UserDefaultsManager().saveToUserDefaults(false, forKey: AppConfig.UserDefaultsConfig.login)
                    UserDefaultsManager().saveToUserDefaults(false, forKey: AppConfig.UserDefaultsConfig.guestMode)
                    AppHelpers.changeRootViewControllerFromWindow(.login)
                } else {
                    debugPrint("실행 취소")
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// 앱스토어 링크로 이동하는 메소드
    func pushURLPage(_ page: SettingURLModel) -> (() -> Void)? {
        return {
            let pageUrl = page.urlString
            if let url = URL(string: pageUrl), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                debugPrint(page.urlString, "이동")
            } else {
                debugPrint("페이지 이동 실패", "\(pageUrl)은 이동할 수 없는 URL 입니다.")
            }
        }
    }
    
    func toggleNotificationSetting() {
        NotificationPermissionCheck.check(completion: { [weak self] isOn in
            guard let self else { return }
            
            if isOn {
                self.alarmAlert.message = "알람 설정을 해제하시겠습니까?\n(확인 클릭 시 설정으로 이동)"
            } else {
                self.alarmAlert.message = "알람을 설정 하시겠습니까?\n(확인 클릭 시 설정으로 이동)"
            }
            
            DispatchQueue.main.async {
                self.alarmAlert.showAlert(.alert)
                    .asSignal(onErrorJustReturn: false)
                    .emit { isConfirm in
                        if isConfirm {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        } else {
                            debugPrint("알람 설정 취소")
                        }
                    }
                    .disposed(by: self.disposeBag)
            }
            
        })
    }
    
}
