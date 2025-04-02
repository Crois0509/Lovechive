//
//  LoginAlertViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseFirestore

final class LoginAlertViewModel: ViewModelMethodManager, ViewModelType {
    
    struct Input {
        let firstButtonTapped: ControlEvent<Void>
        let secondButtonTapped: ControlEvent<Void>
        let inputDataRelay: BehaviorRelay<String>
    }
    
    struct Output {
        let changeCurrentType: PublishRelay<LoginAlertType>
        let pushMainView: PublishRelay<Void>
    }
    
    private var disposeBag = DisposeBag()
    private var currentType: LoginAlertType
    private let alert = AlertManager(title: "경고", message: "10자리 코드를 모두 입력해 주세요!", cancelTitle: "확인")
    private let errorAlert = AlertManager(title: "경고", message: "커플 등록에 실패했습니다.\n잠시 후 다시 시도해 주세요.", cancelTitle: "확인")
    
    private var userId: String? = ""
    private var userName: String? = ""
    
    private let changeCurrentType = PublishRelay<LoginAlertType>()
    private let inputDataRelay = BehaviorRelay<String>(value: "")
    private let pushMainView = PublishRelay<Void>()
    
    private let startButtonTapped = PublishRelay<Void>()
    private let shareButtonTapped = PublishRelay<Void>()
    
    init(type: LoginAlertType) {
        self.currentType = type
    }
    
    func transform(input: Input) -> Output {
        
        input.firstButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                if owner.currentType == .start {
                    owner.changeCurrentAlertType(.code)
                    owner.currentType = .code
                } else {
                    owner.activeButtonAction()
                }
            }
            .disposed(by: disposeBag)
        
        input.secondButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.changeCurrentAlertType(.new)
                owner.currentType = .new
            }
            .disposed(by: disposeBag)
        
        input.inputDataRelay
            .bind(to: inputDataRelay)
            .disposed(by: disposeBag)
        
        shareButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.shareCoupleId()
            }
            .disposed(by: disposeBag)
        
        startButtonTapped
            .withUnretained(self)
            .map { owner, _ in owner.inputDataRelay.value }
            .flatMap { [weak self] text -> Observable<Bool> in
                guard let self else { return .just(false) }
                let checkCode = text.count == 10
                
                if checkCode {
                    return .just(true)
                } else {
                    return self.alert.showAlert(.alert)
                }
            }
            .flatMap { [weak self] conditionsEstablished -> Single<[QueryDocumentSnapshot]> in
                guard let self else { return .just([]) }
                if conditionsEstablished {
                    return FirestoreManager.shared.readFromFirestore(type: .couple(id: self.inputDataRelay.value))
                } else {
                    return .just([])
                }
            }
            .flatMap { [weak self] query -> Single<Bool> in
                guard let self else { return .just(false) }
                return self.checkDataIsEmpty(query)
            }
            .flatMap { [weak self] isEmpty -> Single<[QueryDocumentSnapshot]> in
                guard let self else { return .just([]) }
                
                if !isEmpty {
                    return FirestoreManager.shared.readFromFirestore(type: .user)
                } else {
                    return self.errorAlert.showAlert(.alert)
                        .asSingle()
                        .flatMap { _ in Single.just([QueryDocumentSnapshot]()) }
                }
            }
            .compactMap { [weak self] query -> UserDataModel? in
                self?.mappingUserData(query)
            }
            .flatMap { data -> Single<Bool> in
                return FirestoreManager.shared.saveToFirestore(data, type: .user)
            }
            .flatMap { [weak self] isSuccess -> Single<[QueryDocumentSnapshot]> in
                guard let self else { return .just([]) }
                if isSuccess {
                    return FirestoreManager.shared.readFromFirestore(type: .couple(id: self.inputDataRelay.value))
                } else {
                    return .just([])
                }
            }
            .compactMap { [weak self] query -> CoupleDataModel? in
                self?.mappingCoupleData(query)
            }
            .flatMap { [weak self] data -> Single<Bool> in
                guard let self else { return .just(false) }
                return FirestoreManager.shared.saveToFirestore(data, type: .couple(id: self.inputDataRelay.value))
            }
            .flatMap { isSuccess -> Single<Bool> in
                if isSuccess {
                    return FirestoreManager.shared.deleteFromFirestore(type: .couple(id: nil))
                } else {
                    return .just(false)
                }
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] isSuccess in
                guard let self else { return }
                
                if isSuccess {
                    debugPrint("✅ 정보 저장 성공")
                    UserDefaultsManager().saveToUserDefaults(self.inputDataRelay.value, forKey: AppConfig.UserDefaultsConfig.coupleId)
                    UserDefaultsManager().saveToUserDefaults(true, forKey: AppConfig.UserDefaultsConfig.login)
                    UserDefaultsManager().saveToUserDefaults(false, forKey: AppConfig.UserDefaultsConfig.ready)
                    self.pushMainView.accept(())
                } else {
                    debugPrint("❌ 정보 저장 실패")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(changeCurrentType: changeCurrentType,
                      pushMainView: pushMainView
        )
    }
    
}

private extension LoginAlertViewModel {
    
    func changeCurrentAlertType(_ type: LoginAlertType) {
        switch type {
        case .start: break
        case .code:
            changeCurrentType.accept(.code)
            self.currentType = .code
            
        case .new:
            changeCurrentType.accept(.new)
            self.currentType = .new
        }
    }
    
    func activeButtonAction() {
        switch currentType {
        case .start: break
        case .code:
            shareButtonTapped.accept(())
            
        case .new:
            startButtonTapped.accept(())
        }
    }
    
    func checkDataIsEmpty(_ data: [QueryDocumentSnapshot]) -> Single<Bool> {
        return Single.create { single in
            
            if data.isEmpty {
                single(.success(true))
                debugPrint("🗑️ 커플 데이터가 존재하지 않습니다.")
                
            } else if let user1Id = (data.first?.data()[AppConfig.CouplesModel.user1Id] as? String),
                      let user2Id = (data.first?.data()[AppConfig.CouplesModel.user2Id] as? String)
            {
                if user1Id.isEmpty || user2Id.isEmpty {
                    single(.success(false))
                    debugPrint("✅ 커플 등록이 가능합니다.")
                    
                } else {
                    single(.success(true))
                    debugPrint("🚨 이미 등록된 커플이 존재합니다.")
                }
                
            } else {
                single(.success(true))
                debugPrint("❌ 커플 등록이 불가능 합니다.")
            }
            
            return Disposables.create()
        }
    }
    
    func mappingUserData(_ query: [QueryDocumentSnapshot]) -> UserDataModel? {
        guard !query.isEmpty else { return nil }
        let userData = query.compactMap { [weak self] query -> UserDataModel? in
            guard let self else { return nil }
            return UserDataModel(id: UserDefaults.standard.string(forKey: AppConfig.UserDefaultsConfig.userId) ?? "",
                                 name: query.data()[AppConfig.UserModel.name] as? String ?? "",
                                 email: query.data()[AppConfig.UserModel.email] as? String ?? "",
                                 coupleId: self.inputDataRelay.value,
                                 birthDay: (query.data()[AppConfig.UserModel.birthDay] as? Timestamp)?.dateValue() ?? Date(),
                                 createdAt: (query.data()[AppConfig.UserModel.createdAt] as? Timestamp)?.dateValue() ?? Date()
            )
        }.first
        
        userId = userData?.id
        userName = userData?.name
        
        return userData
    }
    
    func mappingCoupleData(_ query: [QueryDocumentSnapshot]) -> CoupleDataModel? {
        guard !query.isEmpty else { return nil }
        
        let coupleData = query.compactMap { [weak self] query -> CoupleDataModel? in
            guard let self,
                  let user1Id = query.data()[AppConfig.CouplesModel.user1Id] as? String,
                  let user2Id = query.data()[AppConfig.CouplesModel.user2Id] as? String
            else { return nil }
            
            if user1Id.isEmpty {
                return CoupleDataModel(user1Id: self.userId ?? "",
                                       user2Id: query.data()[AppConfig.CouplesModel.user2Id] as? String ?? "",
                                       user1Name: self.userName ?? "",
                                       user2Name: query.data()[AppConfig.CouplesModel.user2Name] as? String ?? "",
                                       dDay: (query.data()[AppConfig.CouplesModel.dDay] as? Timestamp)?.dateValue() ?? Date()
                )
                
            } else if user2Id.isEmpty {
                return CoupleDataModel(user1Id: query.data()[AppConfig.CouplesModel.user1Id] as? String ?? "",
                                       user2Id: self.userId ?? "",
                                       user1Name: query.data()[AppConfig.CouplesModel.user1Name] as? String ?? "",
                                       user2Name: self.userName ?? "",
                                       dDay: (query.data()[AppConfig.CouplesModel.dDay] as? Timestamp)?.dateValue() ?? Date()
                )
                
            } else {
                return CoupleDataModel(user1Id: self.userId ?? "",
                                       user2Id: query.data()[AppConfig.CouplesModel.user2Id] as? String ?? "",
                                       user1Name: self.userName ?? "",
                                       user2Name: query.data()[AppConfig.CouplesModel.user2Name] as? String ?? "",
                                       dDay: (query.data()[AppConfig.CouplesModel.dDay] as? Timestamp)?.dateValue() ?? Date()
                )
            }
            
        }.first
        
        return coupleData
    }
    
    func shareCoupleId() {
        guard let topVC = AppHelpers.getTopViewController() else { return }
        var shareItems = [String]()
        
        let coupleId = UserDefaultsManager().coupleId
        let url = AppConfig.SettingConfig.appstoreLink
        let text: String = "🩷Lovechive 초대장이 도착했어요🩷\n앱을 설치하고 아래 코드를 입력하여 연인과 Lovechive 앱을 즐겨보세요!!\n\n<\(coupleId)>\n설치 링크: \(url)"
        shareItems.append(text)

        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = topVC.view
        topVC.present(activityViewController, animated: true, completion: nil)
    }
    
}
