//
//  AlerttextFieldView.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AlertTextFieldView: UIView {
    
    fileprivate let textField = UITextField()
    fileprivate let extraView: UIView
    
    init(type: AlertTextFieldModel, placeHolder: String) {
        switch type {
        case .limit:
            extraView = UILabel()
        case .time, .calendar:
            extraView = UIButton()
        }
        
        super.init(frame: .zero)
        setupExtraView(type: type)
        textField.setPlaceholder(title: placeHolder, color: .Gray.secondary)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension AlertTextFieldView {
    
    func setupUI() {
        setuptextField()
        configrueSelf()
        setupLayout()
    }
    
    func configrueSelf() {
        backgroundColor = .clear
        [textField, extraView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        textField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        if extraView is UILabel {
            extraView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalTo(textField).inset(8)
                $0.height.equalTo(20)
            }
        } else {
            extraView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalTo(textField).inset(8)
                $0.width.height.equalTo(20)
            }
        }
    }
    
    func setupExtraView(type: AlertTextFieldModel) {
        switch type {
        case .limit(value: let value):
            guard let label = extraView as? UILabel else { return }
            label.text = "0/\(value)" // 기본 값
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .Gray.secondary
            label.numberOfLines = 1
            label.textAlignment = .right
            label.backgroundColor = .clear
            label.lineBreakMode = .byClipping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        case .time, .calendar:
            guard let button = extraView as? UIButton else { return }
            button.setImage(type.buttonImage, for: .normal)
            button.backgroundColor = .clear
            button.imageView?.contentMode = .scaleAspectFit
            button.setContentHuggingPriority(.required, for: .horizontal)

            textField.isUserInteractionEnabled = false
        }
    }
    
    func setuptextField() {
        textField.font = .systemFont(ofSize: 14, weight: .regular)
        textField.textColor = .Gray.naturalBlack
        textField.borderStyle = .none
        textField.clipsToBounds = true
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 8, height: 8))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: .init(x: 0, y: 0, width: 48, height: 8))
        textField.rightViewMode = .always
        textField.autocapitalizationType = .none
        textField.backgroundColor = .white
        
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.Gray.secondary.cgColor
    }
    
}

extension Reactive where Base: AlertTextFieldView {
    var editingTextField: ControlProperty<String?> {
        base.textField.rx.text
    }
}
