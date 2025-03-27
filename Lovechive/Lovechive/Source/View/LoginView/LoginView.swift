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
    fileprivate let guestModeButton = UIButton()
    
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
        setupGuestModeButton()
        setupAppleButton()
        setupLogo()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .Personal.backgroundPink
        [logoView, guestModeButton, appleLogin].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        logoView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(150)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(224)
        }
        
        guestModeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(56)
        }
        
        appleLogin.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(guestModeButton.snp.top).offset(-8)
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
    
    func setupGuestModeButton() {
        guestModeButton.setTitle("게스트로 로그인", for: .normal)
        guestModeButton.setTitleColor(.white, for: .normal)
        guestModeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        guestModeButton.tintColor = .white
        guestModeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        guestModeButton.titleLabel?.textAlignment = .center
        guestModeButton.layer.cornerRadius = 8
        guestModeButton.backgroundColor = .Personal.highlightPink
    }

}

// MARK: - Reactive Extension

extension Reactive where Base: LoginView {
    var appleLoginButtonTapped: ControlEvent<Void> {
        base.appleLogin.rx.controlEvent(.touchUpInside)
    }
    
    var guestButtonTapped: ControlEvent<Void> {
        base.guestModeButton.rx.tap
    }
}
