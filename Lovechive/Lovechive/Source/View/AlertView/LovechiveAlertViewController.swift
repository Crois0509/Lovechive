//
//  LovechiveAlertViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LovechiveAlertViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private let viewModel = LovechiveAlertViewModel()
    
    private let alertView: LovechiveAlertView
    private let dim = UIView()
    
    init(type: AlertTypes) {
        alertView = .init(type: type)
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
        
        showAlertView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    func dismissSelf(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            self.dim.alpha = 0
            self.alertView.frame.origin.y = self.view.frame.maxY + 50
        } completion: { _ in
            completion()
        }
    }
}

private extension LovechiveAlertViewController {
    
    func setupUI() {
        setupDim()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .clear
        [dim, alertView].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        dim.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        alertView.frame.origin.y = view.frame.maxY + 50
    }
    
    func setupDim() {
        dim.backgroundColor = .black
        dim.alpha = 0
    }
    
    func showAlertView() {
        UIView.animate(withDuration: 0.3) {
            self.dim.alpha = 0.25
            self.alertView.frame.origin.y = self.view.frame.midY
        } completion: { _ in
            // 키보드 열기
        }
    }
    
    func bind() {
        let input = LovechiveAlertViewModel.Input(cancelButtonTapped: alertView.rx.cancelButtonTapped,
                                                  activeButtonTapped: alertView.rx.activeButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        alertView.rx.layoutSubviewsEvent
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.alertView.updateSectionViewSize()
            }
            .disposed(by: disposeBag)
    }
    
}
