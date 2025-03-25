//
//  EditMyTextFieldView.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditMyTextFieldView: UIView {
    
    private var disposeBag = DisposeBag()
    
    // MARK: -  UI Components
    
    private let titleView = UILabel()
    fileprivate let textField = UITextView()
    private let placeHoler = UILabel()
    private let limitLabel = UILabel()
    
    // MARK: - Initializer
    
    init(title: String, text: String) {
        super.init(frame: .zero)
        
        titleView.text = title
        placeHoler.text = text
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 텍스트필드를 설정하는 메소드
    /// - Parameter text: 텍스트필드에 입력할 텍스트
    func configureTextField(_ text: String) {
        textField.text = text
    }
}

// MARK: - UI Setting Method

private extension EditMyTextFieldView {
    
    func setupUI() {
        setupTextField()
        setupPlaceHolder()
        setupLimitVeiw()
        setupLabel()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [titleView, textField, placeHoler, limitLabel].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(120)
            $0.bottom.equalToSuperview()
        }
        
        placeHoler.snp.makeConstraints {
            $0.top.leading.equalTo(textField).inset(8)
        }
        
        limitLabel.snp.makeConstraints {
            $0.trailing.bottom.equalTo(textField).inset(8)
        }
    }
    
    func setupLabel() {
        titleView.font = .systemFont(ofSize: 14, weight: .medium)
        titleView.textColor = .Personal.highlightPink
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupLimitVeiw() {
        limitLabel.text = "0/200" // 기본 값
        limitLabel.font = .systemFont(ofSize: 14, weight: .regular)
        limitLabel.textColor = .Gray.secondary
        limitLabel.numberOfLines = 1
        limitLabel.textAlignment = .right
        limitLabel.backgroundColor = .clear
        limitLabel.lineBreakMode = .byClipping
        limitLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func setupPlaceHolder() {
        placeHoler.font = .systemFont(ofSize: 14, weight: .regular)
        placeHoler.textColor = .Gray.secondary
        placeHoler.numberOfLines = 1
        placeHoler.textAlignment = .left
        placeHoler.backgroundColor = .clear
    }
    
    func setupTextField() {
        textField.keyboardType = .default
        textField.textContainer.lineFragmentPadding = 8
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .Gray.naturalBlack
        textField.clipsToBounds = true
        textField.autocapitalizationType = .none
        textField.backgroundColor = .white
        
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.Gray.secondary.cgColor
    }
    
    func checkInputLimit(_ input: String, _ view: UILabel) -> String {
        guard let text = view.text,
              let limitString = text.split(separator: "/").last?.trimmingCharacters(in: .whitespaces),
              let limit = Int(limitString)
        else { return input }
        
        let isOverLimit = input.count >= limit
        let trimmedInput = isOverLimit ? String(input.prefix(limit)) : input
        
        view.textColor = isOverLimit ? .systemRed : .Gray.secondary
        
        if isOverLimit {
            HapticDrawer.notification(type: .warning)
        }
        
        return trimmedInput
    }
    
    func mappingLimitText(_ view: UILabel, _ text: String) -> String {
        let slice = view.text?.split(separator: "/")
        let currentText = text.count
        let limit = "\(currentText)/\(slice?.last ?? "")"
        
        return limit
    }
    
    func bind() {
        textField.rx.text.orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .map { owner, text in owner.checkInputLimit(text, owner.limitLabel) }
            .asDriver(onErrorDriveWith: .empty())
            .drive { [weak self] text in
                guard let self else { return }
                self.textField.text = text
                self.limitLabel.text = self.mappingLimitText(self.limitLabel, text)
                self.placeHoler.isHidden = !text.isEmpty
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: EditMyTextFieldView {
    /// TextField의 값이 변경되었을 때 이벤트를 방출하는 메소드
    var editingTextField: ControlProperty<String> {
        base.textField.rx.text.orEmpty
    }
}
