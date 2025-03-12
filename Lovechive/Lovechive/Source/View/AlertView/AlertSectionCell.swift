//
//  AlertSectionCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit

final class AlertSectionCell: UICollectionViewCell {
    
    func configureCell(_ view: UIView) {
        addSubview(view)
        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
