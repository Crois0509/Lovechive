//
//  LoginAlertViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginAlertViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private var viewModel: LoginAlertViewModel
    
    private let icon = UIImageView()
    private let lovechive = UIImageView()
    
    private let dim = UIView()
    private let loginAlert: LoginAlertView
    
    init(type: LoginAlertType) {
        self.loginAlert = LoginAlertView(type: type)
        self.viewModel = LoginAlertViewModel(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showAlert()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
}

// MARK: - UI Setting Method

private extension LoginAlertViewController {
    
    func setupUI() {
        setupImageViews()
        setupDim()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .Personal.backgroundPink
        [icon, lovechive, dim, loginAlert].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        
        icon.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.height.width.equalTo(224)
            $0.centerX.equalToSuperview()
        }
        
        lovechive.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(80)
            $0.width.equalTo(150)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        dim.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loginAlert.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().inset(32)
            $0.height.greaterThanOrEqualTo(100)
        }
        
        loginAlert.frame.origin.y = view.frame.maxY + 50
        
    }
    
    func setupImageViews() {
        icon.image = .loginIcon
        icon.contentMode = .scaleAspectFit
        icon.backgroundColor = .clear
        
        lovechive.image = .lovechive
        lovechive.contentMode = .scaleAspectFit
        lovechive.backgroundColor = .clear
    }
    
    func setupDim() {
        dim.backgroundColor = .black.withAlphaComponent(0.25)
        dim.alpha = 0
    }
    
    func showAlert() {
        UIView.animate(withDuration: 0.3) {
            self.dim.alpha = 1
            self.loginAlert.frame.origin.y = self.view.frame.midY
        }
    }
    
    func bind() {
        let input = LoginAlertViewModel.Input(firstButtonTapped: loginAlert.rx.firstButtonTapped,
                                              secondButtonTapped: loginAlert.rx.secondButtonTapped,
                                              inputDataRelay: loginAlert.rx.inputDataRelay
        )
        
        let output = viewModel.transform(input: input)
        
        output.changeCurrentType
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, state in
                owner.loginAlert.changeAlertType(state)
                owner.loginAlert.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
        
        output.pushMainView
            .asSignal(onErrorSignalWith: .empty())
            .emit { _ in
                AppHelpers.changeRootViewControllerFromWindow(.main)
            }
            .disposed(by: disposeBag)
    }
}
