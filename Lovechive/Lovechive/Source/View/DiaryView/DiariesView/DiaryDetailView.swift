//
//  DiaryDetailView.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DiaryDetailView: UIView {
    
    private let titleView = UILabel()
    private let imageView = UIImageView()
    private let contentsView = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDiary(_ data: DiaryDataModel) {
        let image = ImageManager.shared.loadImage(path: data.image)
        
        titleView.text = data.title
        contentsView.text = data.content
        
        if let image {
            setupImage(image)
        }
    }
    
}

// MARK: - UI Setting Method

private extension DiaryDetailView {
    
    func setupUI() {
        setupTitleView()
        setupImageView()
        setupContentsView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, imageView, contentsView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(0)
        }
        
        contentsView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
    }
    
    func setupTitleView() {
        titleView.font = .myoyaFont(24)
        titleView.textColor = .Personal.highlightPink
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupContentsView() {
        contentsView.font = .myoyaFont(14)
        contentsView.textColor = .Gray.naturalBlack
        contentsView.numberOfLines = 0
        contentsView.textAlignment = .left
        contentsView.backgroundColor = .clear
    }
    
    func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
    }
    
    func setupImage(_ image: UIImage) {
        DispatchQueue.main.async {
            let aspectRatio = image.size.height / image.size.width
            let newHeight = self.imageView.frame.width * aspectRatio
            
            self.imageView.image = image
            self.imageView.snp.updateConstraints {
                $0.height.equalTo(newHeight)
            }
        }
    }
    
}
