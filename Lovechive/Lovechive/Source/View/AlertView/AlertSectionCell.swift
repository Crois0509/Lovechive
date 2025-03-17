//
//  AlertSectionCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit

/// 커스텀 Alert뷰의 재활용 섹션의 셀 모델 정의
final class AlertSectionCell: UICollectionViewCell {
    
    /// 셀을 설정하는 메소드
    /// - Parameter view: 셀에 넣을 뷰
    func configureCell(_ view: UIView) {
        addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
