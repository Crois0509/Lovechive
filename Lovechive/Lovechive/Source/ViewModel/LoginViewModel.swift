//
//  LoginViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseFirestore
import AuthenticationServices

final class LoginViewModel: ViewModelMethodManager, ViewModelType {
    typealias UserInfo = (email: String, id: String, name: String)
    
    struct Input {
        let appleLoginButtonTapped: ControlEvent<Void>
        let guestLoginButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let userDataSaved: PublishRelay<RootViews>
    }
    
    private var disposeBag = DisposeBag()
    
    private var coupleData: CoupleDataModel?
    
    private let alert = AlertManager(title: "알림", message: "로그인에 실패했습니다.\n잠시 후 다시 시도해 주세요.", cancelTitle: "확인")
    private let guestAlert = AlertManager(title: "알림", message: "게스트로 로그인 시\n일부 기능을 이용할 수 없습니다.\n게스트로 로그인 하시겠습니까?", cancelTitle: "취소", activeTitle: "확인")
    
    private let loginSuccess = PublishRelay<UserInfo>()
    private let checkUserData = BehaviorRelay<UserInfo>(value: ("", "", ""))
    private let userDataSaved = PublishRelay<RootViews>()
    
    func transform(input: Input) -> Output {
        
        input.guestLoginButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.guestAlert.showAlert(.alert)
            }
            .asSignal(onErrorJustReturn: false)
            .emit { [weak self] isConfirm in
                if isConfirm {
                    UserDefaultsManager().saveToUserDefaults(true, forKey: AppConfig.UserDefaultsConfig.guestMode)
                    self?.userDataSaved.accept(.main)
                } else {
                    debugPrint("게스트모드 로그인 취소")
                }
            }
            .disposed(by: disposeBag)
        
        input.appleLoginButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.didTapAppleSignIn()
                // owner.testLogin()
            }
            .disposed(by: disposeBag)
        
        checkUserData
            .skip(1)
            .flatMap { _ in
                return FirestoreManager.shared.readFromFirestore(type: .user)
            }
            .withUnretained(self)
            .compactMap { owner, query -> String? in
                if query.isEmpty {
                    owner.loginSuccess.accept(owner.checkUserData.value)
                    debugPrint("🎉 신규 가입 유저")
                    return nil
                } else if let coupleId = query.first?.data()[AppConfig.UserModel.coupleId] as? String {
                    UserDefaultsManager().saveToUserDefaults(coupleId, forKey: AppConfig.UserDefaultsConfig.coupleId)
                    debugPrint("📂 커플 등록 여부 확인...")
                    return coupleId
                } else {
                    debugPrint("🚨 커플 ID 추출 실패")
                    return nil
                }
            }
            .flatMap { coupleId -> Single<[QueryDocumentSnapshot]> in
                return FirestoreManager.shared.readFromFirestore(type: .couple(id: coupleId))
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] query in
                guard let self else { return }
                
                if query.isEmpty {
                    self.loginSuccess.accept(self.checkUserData.value)
                    debugPrint("❌ 커플 미등록 유저")
                    
                } else if let user1Id = query.first?.data()[AppConfig.CouplesModel.user2Id] as? String,
                          let user2Id = query.first?.data()[AppConfig.CouplesModel.user2Id] as? String
                {
                    if user1Id.isEmpty || user2Id.isEmpty {
                        self.loginSuccess.accept(self.checkUserData.value)
                        debugPrint("❌ 커플 미등록 유저")
                        
                    } else {
                        UserDefaultsManager().saveToUserDefaults(true, forKey: AppConfig.UserDefaultsConfig.login)
                        self.userDataSaved.accept(.main)
                        debugPrint("✅ 커플 등록 유저")
                    }
                } else {
                    self.loginSuccess.accept(self.checkUserData.value)
                    debugPrint("❌ 커플 미등록 유저")
                }
            }
            .disposed(by: disposeBag)
        
        loginSuccess
            .withUnretained(self)
            .map { owner, userInfo in
                return owner.mappingUserData(userInfo)
            }
            .flatMap { data in
                return FirestoreManager.shared.saveToFirestore(data, type: .user)
            }
            .flatMap { [weak self] isSuccess -> Single<Bool> in
                guard let self else { return .just(false) }
                
                if isSuccess, let data = self.coupleData {
                    return FirestoreManager.shared.saveToFirestore(data, type: .couple(id: nil))
                } else {
                    return .just(false)
                }
            }
            .flatMap { [weak self] isSuccess -> Observable<Bool> in
                guard let self else { return .just(false) }
                if isSuccess {
                    debugPrint("✅ 사용자 정보 저장 완료")
                    return .just(true)
                } else {
                    debugPrint("❌ 사용자 정보 저장 실패")
                    return self.alert.showAlert(.alert)
                }
            }
            .asSignal(onErrorJustReturn: false)
            .emit { [weak self] isSuccess in
                if isSuccess {
                    UserDefaultsManager().saveToUserDefaults(true, forKey: AppConfig.UserDefaultsConfig.ready)
                    self?.userDataSaved.accept(.start)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(userDataSaved: userDataSaved)
    }
    
}

private extension LoginViewModel {
    
    func mappingUserData(_ data: UserInfo) -> UserDataModel {
        let coupleId: String = String(UUID().uuidString.uppercased().split(separator: "-").joined().shuffled().prefix(10))
        UserDefaultsManager().saveToUserDefaults(data.id, forKey: AppConfig.UserDefaultsConfig.userId)
        UserDefaultsManager().saveToUserDefaults(coupleId, forKey: AppConfig.UserDefaultsConfig.coupleId)
        
        createdCoupleData(data.id, data.name)
        
        return UserDataModel(id: data.id,
                             name: data.name,
                             email: data.email,
                             coupleId: coupleId,
                             birthDay: Date(),
                             createdAt: Date()
        )
    }
    
    func createdCoupleData(_ id: String, _ name: String) {
        let data = CoupleDataModel(user1Id: id,
                                   user2Id: "",
                                   user1Name: name,
                                   user2Name: "",
                                   dDay: Date())
        
        coupleData = data
    }
    
    func didTapAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        // 사용자에게 제공받을 정보 설정
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self // 로그인 정보 관련 대리자 설정
        controller.presentationContextProvider = self // 인증창을 보여주기 위한 대리자 설정
        controller.performRequests() // 요청
    }
    
    // TODO: 로그인 기능 테스트를 위한 기능
    func testLogin() {
        let email: String = "test1234@naver.com"
        let id: String = UUID().uuidString
        let name: String = "테스트"
        
        UserDefaultsManager().saveToUserDefaults(id, forKey: AppConfig.UserDefaultsConfig.userId)
        debugPrint(email, id, name)
        
        checkUserData.accept((email, id, name))
    }
    
}

extension LoginViewModel: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let topVC = AppHelpers.getTopViewController() else { return UIWindow() }
        return topVC.view.window ?? UIWindow()
    }
    
}

extension LoginViewModel: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        alert.showAlert(.alert)
            .subscribe { _ in
                debugPrint("❌ 로그인 실패", error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            
            let userIdentifier = appleIdCredential.user
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            
            let identityToken = appleIdCredential.identityToken
            let authorizationCode = appleIdCredential.authorizationCode
            
            debugPrint("Apple ID 로그인에 성공하였습니다.")
            debugPrint("사용자 ID: \(userIdentifier)")
            debugPrint("전체 이름: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            debugPrint("이메일: \(email ?? "")")
            debugPrint("Token: \(identityToken!)")
            debugPrint("authorizationCode: \(authorizationCode!)")
            
            let userName: String = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            let userEmail: String = email ?? ""
            let userId: String = userIdentifier
            
            // 로그인 성공 후 작업
            UserDefaultsManager().saveToUserDefaults(userId, forKey: AppConfig.UserDefaultsConfig.userId)
            debugPrint(userEmail, userId, userName)
            
            checkUserData.accept((userEmail, userId, userName))
            
        default: break
            
        }
    }
    
}
