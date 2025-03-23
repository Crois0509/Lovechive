//
//  LabelButton.swift
//  Lovechive
//
//  Created by 장상경 on 3/23/25.
//

import UIKit
import SnapKit

final class LabelButton: UIButton {
    
    private let titleView = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        self.titleView.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension LabelButton {
    
    func setupUI() {
        setupLabel()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        addSubview(titleView)
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    func setupLabel() {
        titleView.textColor = .Gray.naturalBlack
        titleView.font = .systemFont(ofSize: 14, weight: .regular)
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
}
