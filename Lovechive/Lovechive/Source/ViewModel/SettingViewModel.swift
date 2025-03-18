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

final class SettingViewModel: ViewModelType {
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let editButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let sections: BehaviorRelay<[SetTableSection]>
        let myPageDataRelay: Observable<MyPageDataModel>
    }
    
    private var disposeBag = DisposeBag()
    
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
    
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
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
    
    private func fetchData(_ type: FirestoreDataTypes) -> Single<[QueryDocumentSnapshot]> {
        FirestoreManager.shared.readFromFirestore(type: type)
    }
    
    private func mappingUserData(_ query: [QueryDocumentSnapshot]) -> UserDataModel? {
        guard let user = query.first else { return nil }
        
        return UserDataModel(id: user.data()[AppConfig.UserModel.id] as? String ?? "",
                             name: user.data()[AppConfig.UserModel.name] as? String ?? "",
                             email: user.data()[AppConfig.UserModel.email] as? String ?? "",
                             coupleId: user.data()[AppConfig.UserModel.coupleId] as? String ?? "",
                             birthDay: (user.data()[AppConfig.UserModel.birthDay] as? Timestamp)?.dateValue() ?? Date(),
                             createdAt: (user.data()[AppConfig.UserModel.createdAt] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    private func mappingCoupleData(_ query: [QueryDocumentSnapshot]) -> CoupleDataModel? {
        guard let couple = query.first else { return nil }
        
        return CoupleDataModel(user1Id: couple.data()[AppConfig.CouplesModel.user1Id] as? String ?? "",
                               user2Id: couple.data()[AppConfig.CouplesModel.user2Id] as? String ?? "",
                               user1Name: couple.data()[AppConfig.CouplesModel.user1Name] as? String ?? "",
                               user2Name: couple.data()[AppConfig.CouplesModel.user2Name] as? String ?? "",
                               dDay: (couple.data()[AppConfig.CouplesModel.dDay] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    private func showAlertView(type: AlertTypes) -> PublishRelay<Bool> {
        let vc = AppHelpers.getTopViewController()
        let alert = LovechiveAlertViewController(type: type)
        vc?.addChild(alert)
        vc?.view.addSubview(alert.view)
        alert.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alert.didMove(toParent: vc)
        
        return alert.rx.dataSavedRelay
    }
}

// MARK: - SettingTableCellModel Private Method

private extension SettingViewModel {
    
    // 설정탭에 넣을 셀을 정의하는 프로퍼티
    var defaultSettingModels: [SettingTableCellModel] {
        return [
            SettingTableCellModel(
                title: "알림 설정",
                extraView: setupSwitch(),
                action: nil
            ),
            
            SettingTableCellModel(
                title: "개인정보처리방침",
                extraView: setupLabel(">"),
                action: nil
            ),
            
            SettingTableCellModel(
                title: "사용 방법",
                extraView: setupLabel(">"),
                action: nil
            ),
            
            SettingTableCellModel(
                title: "앱 리뷰 남기기",
                extraView: setupLabel(">"),
                action: moveAppstore
            ),
            
            SettingTableCellModel(
                title: "버그 제보 / 문의",
                extraView: setupLabel(">"),
                action: nil
            ),
            
            SettingTableCellModel(
                title: "앱 버전",
                extraView: setupLabel(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"),
                action: nil
            )
        ]
    }
    
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
    
    func setupNotificationPermission() {
        
    }
    
    /// 문의 기능을 Alert으로 구현한 메소드
    func inquiry() {
        debugPrint(#function)
    }
    
    /// 앱스토어 링크로 이동하는 메소드
    func moveAppstore() {
        let appUrl = "itms-apps://apps.apple.com/app/id6741835898" // TODO: 추후 id 수정 필요
        if let url = URL(string: appUrl), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        debugPrint("앱스토어 이동")
    }
    
    func showOnboarding() {
        debugPrint(#function)
    }
}
