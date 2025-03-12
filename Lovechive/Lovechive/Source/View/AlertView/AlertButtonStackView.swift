//
//  AlertButtonStackView.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AlertButtonStackView: UIView {
    
    fileprivate lazy var cancelButton = createdButton(title: "취소", color: .Gray.naturalBlack, backColor: .clear)
    fileprivate lazy var activeButton = createdButton(title: "만들기", color: .white, backColor: .Personal.highlightPink)
        
    init(aletType: AlertTypes) {
        super.init(frame: .zero)
        
        setupUI()
        activeButton.setTitle(aletType.alertActiveButtonTitle, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension AlertButtonStackView {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [activeButton, cancelButton].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        activeButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(72)
        }
        
        cancelButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalTo(activeButton.snp.leading).offset(-8)
            $0.width.equalTo(72)
        }
    }
    
    func createdButton(title: String, color: UIColor, backColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.backgroundColor = backColor
        button.layer.cornerRadius = 8
        
        return button
    }
    
}

extension Reactive where Base: AlertButtonStackView {
    var cancelButtonTapped: ControlEvent<Void> {
        base.cancelButton.rx.tap
    }
    
    var activeButtonTapped: ControlEvent<Void> {
        base.activeButton.rx.tap
    }
}
