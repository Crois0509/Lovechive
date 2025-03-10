//
//  LatestDiaryView.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import UIKit
import SnapKit

final class LatestDiaryView: UIView {
    
    private let titleView = UILabel()
    private let editImageView = UIImageView()
    private let contentView = UILabel()
    private let dateView = UILabel()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(content: String, date: Date, image: String) {
        contentView.text = content
        dateView.text = date.formattedDateAndTime()
        imageView.image = ImageManager.shared.loadImage(url: image) == nil ? .no : ImageManager.shared.loadImage(url: image)
    }
    
}

private extension LatestDiaryView {
    
    func setupUI() {
        setupTitleView()
        setupIconImageView()
        setupContentView()
        setupDateView()
        setupImageView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, editImageView, imageView, contentView, dateView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.width.equalTo(120)
        }
        
        editImageView.snp.makeConstraints {
            $0.centerY.equalTo(titleView)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(20)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.equalTo(editImageView.snp.bottom).offset(16)
            $0.trailing.equalTo(editImageView)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(imageView)
            $0.leading.equalTo(titleView)
            $0.height.equalTo(60)
            $0.trailing.equalTo(imageView.snp.leading).offset(-16)
        }
        
        dateView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom)
            $0.horizontalEdges.equalTo(contentView)
            $0.bottom.equalTo(imageView)
        }
    }
    
    func setupTitleView() {
        titleView.text = AppConfig.LatestDiary.title
        titleView.textColor = .Personal.highlightPink
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
    }
    
    func setupIconImageView() {
        editImageView.image = .Icon.editIcon
        editImageView.contentMode = .scaleAspectFit
        editImageView.backgroundColor = .clear
    }
    
    func setupContentView() {
        contentView.text = AppConfig.LatestDiary.content
        contentView.textColor = .Gray.naturalBlack
        contentView.font = .systemFont(ofSize: 14, weight: .regular)
        contentView.numberOfLines = 2
        contentView.textAlignment = .left
    }
    
    func setupDateView() {
        dateView.text = AppConfig.LatestDiary.date
        dateView.textColor = .Gray.unSelected
        dateView.font = .systemFont(ofSize: 14, weight: .regular)
        dateView.numberOfLines = 1
        dateView.textAlignment = .left
    }
    
    func setupImageView() {
        imageView.image = .no
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .Personal.backgroundPink
    }
    
}
