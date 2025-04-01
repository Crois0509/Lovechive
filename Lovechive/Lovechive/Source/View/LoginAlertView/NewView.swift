//
//  NewView.swift
//  Lovechive
//
//  Created by 장상경 on 3/31/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class NewView: UIView {
    
    private var disposeBag = DisposeBag()
    
    private let text = UILabel()
    fileprivate let textField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Setting Method

private extension NewView {
    
    func setupUI() {
        setupText()
        setupTextField()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [text, textField].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        text.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(text.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview()
        }
    }
    
    func setupText() {
        text.text = "연인에게 공유받은 코드를 입력해 주세요!"
        text.textColor = .Gray.naturalBlack
        text.font = .systemFont(ofSize: 14, weight: .regular)
        text.numberOfLines = 1
        text.textAlignment = .center
        text.backgroundColor = .clear
    }
    
    func setupTextField() {
        textField.keyboardType = .default
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .Personal.deepPink
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 8, height: 8))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: .init(x: 0, y: 0, width: 8, height: 8))
        textField.rightViewMode = .always
        textField.autocapitalizationType = .allCharacters
        textField.backgroundColor = .white
        
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.Gray.secondary.cgColor
        textField.setPlaceholder(title: "10자리 코드를 입력해 주세요", color: .Gray.secondary)
    }
    
    func bind() {
        
        textField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { String($0.prefix(10)) }
            .map { $0.uppercased() }
            .bind(to: textField.rx.text)
            .disposed(by: disposeBag)
        
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: NewView {
    var inputDataRelay: ControlProperty<String> {
        base.textField.rx.text.orEmpty
    }
}
