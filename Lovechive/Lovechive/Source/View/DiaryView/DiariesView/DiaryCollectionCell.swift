//
//  DiaryCollectionCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import UIKit
import SnapKit

final class DiaryCollectionCell: UITableViewCell {
    
    private let diaryImageView = UIImageView()
    private lazy var titleView = createdLabel(.Gray.naturalBlack, 16, .black)
    private lazy var contentsView = createdLabel(.Gray.unSelected, 14, .regular)
    private let containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ data: DiaryDataModel) {
        let image = ImageManager.shared.loadImage(path: data.image) != nil ? ImageManager.shared.loadImage(path: data.image) : UIImage.no
        diaryImageView.image = image
        titleView.text = data.title
        contentsView.text = data.content
    }
    
}

// MARK: - UI Setting Method

private extension DiaryCollectionCell {
    
    func setupUI() {
        setupContainerView()
        setupImageView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
    }
    
    func setupLayout() {
        containerView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        diaryImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
            $0.width.height.equalTo(120)
        }
        
        titleView.snp.makeConstraints {
            $0.top.equalTo(diaryImageView).offset(14)
            $0.leading.equalTo(diaryImageView.snp.trailing).offset(16)
            $0.height.equalTo(21)
        }
        
        contentsView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.leading.equalTo(titleView)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.bottom.equalTo(diaryImageView).inset(14)
        }
    }
    
    func setupContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        [diaryImageView, titleView, contentsView].forEach {
            containerView.addSubview($0)
        }
    }
    
    func setupImageView() {
        diaryImageView.image = .no
        diaryImageView.contentMode = .scaleAspectFit
        diaryImageView.layer.cornerRadius = 8
        diaryImageView.clipsToBounds = true
        diaryImageView.backgroundColor = .clear
    }
    
    func createdLabel(_ color: UIColor, _ size: CGFloat, _ weight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 0
        
        return label
    }
    
}
