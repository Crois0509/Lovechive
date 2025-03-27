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
    }
}

// MARK: - UI Setting Method

private extension LoginViewController {
    
    func changeRootViewController() {
        DispatchQueue.main.async {
            UIView.transition(with: self.view.window!, duration: 0.5, options: .transitionCrossDissolve) {
                self.view.window?.rootViewController = UINavigationController(rootViewController: MainViewController())
            }
        }
    }
    
    func bind() {
        
        let input = LoginViewModel.Input(appleLoginButtonTapped: loginView.rx.appleLoginButtonTapped)
        let output = viewModel.transform(input: input)
        
        output.userDataSaved
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.changeRootViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
}
