//
//  DiaryListCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit

final class DiaryListCell: UICollectionViewCell {
    
    // MARK: -  UI Components
    
    private let icon = UIImageView()
    private lazy var titleView = createdLabel(16, .bold, .Gray.naturalBlack)
    private lazy var subTitleView = createdLabel(12, .regular, .Gray.unSelected)
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reusedCell()
    }
    
    func configureCell(_ data: DiaryListDataModel) {
        titleView.text = data.diaryTitle
        subTitleView.text = data.diarySubTitle
        backgroundColor = data.diaryColor.transStringToColor != nil ? data.diaryColor.transStringToColor : UIColor.Personal.pointPink
    }
    
}

// MARK: - UI Setting Method

private extension DiaryListCell {
    
    func setupUI() {
        setupIcon()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .Personal.pointPink // 기본 색상
        layer.cornerRadius = 16
        [icon, titleView, subTitleView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        icon.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.width.height.equalTo(30)
        }
        
        titleView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(36)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        
        subTitleView.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleView)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
    }
    
    func createdLabel(_ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) -> UILabel {
        let label = UILabel()
        label.textColor = color
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.backgroundColor = .clear
        
        return label
    }
    
    func setupIcon() {
        icon.image = .Icon.diaryIcon
        icon.contentMode = .scaleAspectFit
        icon.backgroundColor = .clear
    }
    
    func reusedCell() {
        titleView.text = ""
        subTitleView.text = ""
    }
}
