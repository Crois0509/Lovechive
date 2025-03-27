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
import AuthenticationServices

final class LoginViewModel: ViewModelMethodManager, ViewModelType {
    typealias UserInfo = (email: String, id: String, name: String)
    
    struct Input {
        let appleLoginButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let userDataSaved: PublishRelay<Void>
    }
    
    private var disposeBag = DisposeBag()
    
    private let alert = AlertManager(title: "알림", message: "로그인에 실패했습니다.\n잠시 후 다시 시도해 주세요.", cancelTitle: "확인")
    
    private let loginSuccess = PublishRelay<UserInfo>()
    private let userDataSaved = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        
        input.appleLoginButtonTapped
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.didTapAppleSignIn()
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
                    self?.userDataSaved.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        return Output(userDataSaved: userDataSaved)
    }
    
}

private extension LoginViewModel {
    
    func mappingUserData(_ data: UserInfo) -> UserDataModel {
        let coupleId: String = String(UUID().uuidString.uppercased().prefix(10))
        UserDefaults.standard.set(data.id, forKey: AppConfig.UserDefaultsConfig.userId)
        
        return UserDataModel(id: data.id,
                             name: data.name,
                             email: data.email,
                             coupleId: coupleId,
                             birthDay: Date(),
                             createdAt: Date()
        )
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
            loginSuccess.accept((userEmail, userId, userName))
            
        default: break
            
        }
    }
    
}
