//
//  FloatingButton.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit

final class FloatingButton: UIButton {
    
    private let plusIcon = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayer()
    }
    
    private func setupUI() {
        backgroundColor = .Personal.highlightPink
        tintColor = .white
        addSubview(plusIcon)
        setupIcon()
    }
    
    private func setupIcon() {
        plusIcon.image = .Icon.plus
        plusIcon.contentMode = .scaleAspectFit
        
        plusIcon.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.center.equalToSuperview()
        }
    }
    
    private func setupLayer() {
        layer.cornerRadius = bounds.height / 2
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
        
        layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: 0)
    }
}
