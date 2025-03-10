//
//  LogoView.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit

/// 프로젝트에서 공용으로 사용할 LogoView
final class LogoView: UIImageView {
    init() {
        super.init(frame: .zero)
        
        image = .logo
        contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
