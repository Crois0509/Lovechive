//
//  LoginAlertView.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginAlertView: UIView {
    
    private let titleView = UILabel()
    fileprivate var contentsView: UIView
    fileprivate let firstButton = UIButton()
    fileprivate let secondButton = UIButton()
    private let buttonStack = UIStackView()
    
    private var type: LoginAlertType
    
    private var disposeBag = DisposeBag()
    
    fileprivate let inputDataRelay = BehaviorRelay<String>(value: "")
    
    init(type: LoginAlertType) {
        self.type = type
        self.contentsView = StartView()
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeAlertType(_ type: LoginAlertType) {
        resetContentView(type)
        resetAlertState()
    }
    
}

// MARK: - UI Setting Method

private extension LoginAlertView {
    
    func setupUI() {
        setupTitleView()
        setupButtons()
        setupStackView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 16
        [titleView, contentsView, buttonStack].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(-1)
            $0.height.equalTo(40)
        }
        
        contentsView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(40)
        }
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(contentsView.snp.bottom).offset(8)
            $0.height.equalTo(40)
            $0.bottom.horizontalEdges.equalToSuperview().inset(-1)
        }
    }
    
    func setupTitleView() {
        titleView.text = type.title
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.textColor = .Personal.highlightPink
        titleView.numberOfLines = 1
        titleView.textAlignment = .center
        titleView.backgroundColor = .clear
        titleView.layer.borderWidth = 1
        titleView.layer.borderColor = UIColor.Gray.secondary.cgColor
    }
    
    func setupButtons() {
        switch type {
        case .start:
            firstButton.setTitle("새로 시작하기", for: .normal)
            firstButton.setTitleColor(.Gray.naturalBlack, for: .normal)
            firstButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            firstButton.backgroundColor = .clear
            firstButton.layer.borderColor = UIColor.Gray.secondary.cgColor
            firstButton.layer.borderWidth = 1
            
            secondButton.setTitle("코드 입력하기", for: .normal)
            secondButton.setTitleColor(.Personal.highlightPink, for: .normal)
            secondButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            secondButton.backgroundColor = .clear
            secondButton.layer.borderColor = UIColor.Gray.secondary.cgColor
            secondButton.layer.borderWidth = 1
            
        case .code:
            firstButton.setTitle("공유하기", for: .normal)
            firstButton.setTitleColor(.Personal.highlightPink, for: .normal)
            firstButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            firstButton.backgroundColor = .clear
            firstButton.layer.borderColor = UIColor.Gray.secondary.cgColor
            firstButton.layer.borderWidth = 1
            
        case .new:
            firstButton.setTitle("시작하기", for: .normal)
            firstButton.setTitleColor(.Personal.highlightPink, for: .normal)
            firstButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
            firstButton.backgroundColor = .clear
            firstButton.layer.borderColor = UIColor.Gray.secondary.cgColor
            firstButton.layer.borderWidth = 1
        }
    }
    
    func setupStackView() {
        buttonStack.axis = .horizontal
        buttonStack.spacing = -0.5
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.backgroundColor = .clear
        
        switch type {
        case .start:
            [firstButton, secondButton].forEach {
                buttonStack.addArrangedSubview($0)
            }
        default:
            buttonStack.addArrangedSubview(firstButton)
        }
    }
    
    func resetContentView(_ type: LoginAlertType) {
        self.type = type
        contentsView.removeFromSuperview()
        contentsView.snp.removeConstraints()
        disposeBag = DisposeBag()
        
        switch type {
        case .start:
            self.contentsView = StartView()
        case .code:
            self.contentsView = CodeView()
        case .new:
            self.contentsView = NewView()
            bind()
        }
        
        addSubview(contentsView)
        bringSubviewToFront(buttonStack)
        
        contentsView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(buttonStack.snp.top).offset(-8)
        }
    }
    
    func resetAlertState() {
        buttonStack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            $0.snp.removeConstraints()
            buttonStack.removeArrangedSubview($0)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.setupButtons()
            self.setupStackView()
            self.titleView.text = self.type.title
        }
    }
    
    func bind() {
        guard let view = contentsView as? NewView else { return }
        
        view.rx.inputDataRelay
            .bind(to: inputDataRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: LoginAlertView {
    var firstButtonTapped: ControlEvent<Void> {
        base.firstButton.rx.tap
    }
    
    var secondButtonTapped: ControlEvent<Void> {
        base.secondButton.rx.tap
    }
    
    var inputDataRelay: BehaviorRelay<String> {
        base.inputDataRelay
    }
}
