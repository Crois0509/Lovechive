//
//  AlertColorSelectView.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AlertColorSelectView: UIView {
    
    private let colorStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension AlertColorSelectView {
    
    func setupUI() {
        setupStackView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        addSubview(colorStackView)
    }
    
    func setupLayout() {
        colorStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupStackView() {
        colorStackView.axis = .horizontal
        colorStackView.spacing = 8
        colorStackView.alignment = .leading
        colorStackView.distribution = .equalSpacing
        colorStackView.backgroundColor = .clear
        AlertColorSetModel.allCases.forEach {
            let button = self.createdButton($0.sendColor)
            self.colorStackView.addArrangedSubview(button)
        }
    }
    
    
    func createdButton(_ color: UIColor?) -> UIButton {
        let button = UIButton()
        button.backgroundColor = color
        button.layer.cornerRadius = 17
        
        return button
    }
}
