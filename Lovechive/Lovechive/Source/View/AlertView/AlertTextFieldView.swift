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
    
    private var disposeBag = DisposeBag()
    
    private var currentType: AlertTextFieldModel
    
    fileprivate let textField = UITextField()
    private let datePicker = UIDatePicker()
    private let extraView: UIView
    
    init(type: AlertTextFieldModel, placeHolder: String) {
        switch type {
        case .limit:
            extraView = UILabel()
        case .time, .calendar:
            extraView = UIButton()
        }
        currentType = type
        
        super.init(frame: .zero)
        textField.setPlaceholder(title: placeHolder, color: .Gray.secondary)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTextField(_ text: String) {
        textField.text = text
        textField.sendActions(for: .valueChanged)
    }
    
}

private extension AlertTextFieldView {
    
    func setupUI() {
        setupExtraView()
        setuptextField()
        configrueSelf()
        setupLayout()
        bind()
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
    
    func setupExtraView() {
        switch currentType {
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
            button.setImage(currentType.buttonImage, for: .normal)
            button.backgroundColor = .clear
            button.imageView?.contentMode = .scaleAspectFit
            button.setContentHuggingPriority(.required, for: .horizontal)

//            textField.isUserInteractionEnabled = false
//            textField.isEnabled = false
            setupDatePicker()
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
    
    func mappingLimitText(_ view: UILabel, _ text: String) -> String {
        let slice = view.text?.split(separator: "/")
        let currentText = text.count
        let limit = "\(currentText)/\(slice?.last ?? "")"
        
        return limit
    }
    
    func checkInputLimit(_ input: String, _ view: UILabel) -> String {
        guard let limit = Int(view.text?.split(separator: "/").last ?? ""),
              input.count > limit
        else { return input }
        
        let text = String(input.prefix(limit))
        
        HapticManager.notification(type: .warning)
        
        return text
    }
    
    func setupDatePicker() {
        switch currentType {
        case .limit: break
        case .time:
            datePicker.datePickerMode = .time
            datePicker.preferredDatePickerStyle = .wheels
        case .calendar:
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissDatePicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
    }
    
    @objc func dismissDatePicker() {
        var date: String = ""
        
        switch currentType {
        case .limit: break
        case .time:
            date = datePicker.date.formattedDateToString(.hourMinute)
        case .calendar:
            date = datePicker.date.formattedDateToString(.yearMonthDay)
        }
        
        textField.text = date
        textField.resignFirstResponder()
    }
    
    func bind() {
        if let button = extraView as? UIButton {
            button.rx.tap
                .withUnretained(self)
                .asSignal(onErrorSignalWith: .empty())
                .emit { owner, _ in
                    owner.textField.becomeFirstResponder()
                }
                .disposed(by: disposeBag)
            
        } else if let label = extraView as? UILabel {
            textField.rx.text.orEmpty
                .distinctUntilChanged()
                .withUnretained(self)
                .map { owner, text in owner.checkInputLimit(text, label) }
                .asDriver(onErrorDriveWith: .empty())
                .drive { [weak self] text in
                    self?.textField.text = text
                    label.text = self?.mappingLimitText(label, text)
                }
                .disposed(by: disposeBag)
        }
    }
    
}

extension Reactive where Base: AlertTextFieldView {
    var editingTextField: ControlProperty<String> {
        base.textField.rx.text.orEmpty
    }
}
