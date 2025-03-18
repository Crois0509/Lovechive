//
//  AlertMyTextFieldView.swift
//  Lovechive
//
//  Created by 장상경 on 3/17/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// MyPage 뷰에서 사용할 커스텀 텍스트필드 뷰
final class AlertMyTextFieldView: UIView {
    
    // MARK: -  UI Components
    
    private let titleView = UILabel()
    fileprivate let textField: AlertTextFieldView
    
    // MARK: - Initializer
    
    init(_ style: AlertTextFieldModel, title: String, text: String) {
        textField = AlertTextFieldView(type: style, placeHolder: text)
        super.init(frame: .zero)
        
        titleView.text = title
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 텍스트필드를 설정하는 메소드
    /// - Parameter text: 텍스트필드에 입력할 텍스트
    func configureTextField(_ text: String) {
        textField.configureTextField(text)
    }
}

// MARK: - UI Setting Method

private extension AlertMyTextFieldView {
    
    func setupUI() {
        setupLabel()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [titleView, textField].forEach {
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
            $0.height.equalTo(40)
        }
    }
    
    func setupLabel() {
        titleView.font = .systemFont(ofSize: 14, weight: .medium)
        titleView.textColor = .Personal.highlightPink
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: AlertMyTextFieldView {
    /// TextField의 값이 변경되었을 때 이벤트를 방출하는 메소드
    var editingTextField: ControlProperty<String> {
        base.textField.rx.editingTextField
    }
}
