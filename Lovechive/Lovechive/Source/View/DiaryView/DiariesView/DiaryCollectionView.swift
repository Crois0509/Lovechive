//
//  DiaryCollectionView.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import UIKit
import SnapKit

final class DiaryCollectionView: UIView {
    
    private(set) lazy var collectionView = UITableView(frame: .zero, style: .plain)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension DiaryCollectionView {
    
    func setupUI() {
        setupCollectionView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .Personal.backgroundPink
        addSubview(collectionView)
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.rowHeight = 168
        collectionView.sectionHeaderHeight = 40
        collectionView.sectionHeaderTopPadding = 16
        collectionView.separatorStyle = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(DiaryCollectionCell.self, forCellReuseIdentifier: AppConfig.DiaryConfig.collectionCellId)
    }

}
