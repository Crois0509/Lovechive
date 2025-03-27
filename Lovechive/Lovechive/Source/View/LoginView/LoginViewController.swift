//
//  LoginViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/27/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private let viewModel = LoginViewModel()
    
    private let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = loginView
        bind()
    }
}

// MARK: - UI Setting Method

private extension LoginViewController {
    
    func bind() {
        
        let input = LoginViewModel.Input(appleLoginButtonTapped: loginView.rx.appleLoginButtonTapped,
                                         guestLoginButtonTapped: loginView.rx.guestButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.userDataSaved
            .asSignal(onErrorSignalWith: .empty())
            .emit { _ in
                AppHelpers.changeRootViewControllerFromWindow(.main)
            }
            .disposed(by: disposeBag)
        
    }
    
}
