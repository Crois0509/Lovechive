//
//  LoginView.swift
//  Lovechive
//
//  Created by 장상경 on 3/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AuthenticationServices

final class LoginView: UIView {
    
    private let logoView = UIImageView()
    fileprivate let appleLogin = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension LoginView {
    
    func setupUI() {
        setupAppleButton()
        setupLogo()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .Personal.backgroundPink
        [logoView, appleLogin].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        logoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(150)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(224)
        }
        
        appleLogin.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(56)
        }
    }
    
    func setupLogo() {
        logoView.image = .loginIcon
        logoView.contentMode = .scaleAspectFit
        logoView.backgroundColor = .clear
    }
    
    func setupAppleButton() {
        appleLogin.cornerRadius = 8
    }

}

// MARK: - Reactive Extension

extension Reactive where Base: LoginView {
    var appleLoginButtonTapped: ControlEvent<Void> {
        base.appleLogin.rx.controlEvent(.touchUpInside)
    }
}
