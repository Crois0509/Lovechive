//
//  DiaryListView.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DiaryListView: UIView {
    
    private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createdLayout())
    fileprivate let addButton = FloatingButton()
    private let infoView = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInfoLabelHidden(_ itemIsEmpty: Bool) {
        infoView.isHidden = !itemIsEmpty
    }
    
}

// MARK: - UI Setting Method

private extension DiaryListView {
    
    func setupUI() {
        setupInfoView()
        setupCollectionView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [collectionView, infoView, addButton].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        infoView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(16)
            $0.width.height.equalTo(72)
        }
    }
    
    func createdLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func setupInfoView() {
        infoView.text = "아직 다이어리가 없습니다.\n다이어리를 만들어 연인과 공유해 보세요!"
        infoView.font = .myoyaFont(24)
        infoView.textColor = .Gray.unSelected
        infoView.numberOfLines = 2
        infoView.textAlignment = .center
        infoView.backgroundColor = .clear
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DiaryListCell.self, forCellWithReuseIdentifier: AppConfig.DiaryConfig.cellId)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: DiaryListView {
    var diaryAddButtonTapped: ControlEvent<Void> {
        base.addButton.rx.tap
    }
}
