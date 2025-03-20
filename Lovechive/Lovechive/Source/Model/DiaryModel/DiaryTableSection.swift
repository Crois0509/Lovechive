//
//  DiaryTableSection.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import Foundation
import RxDataSources

struct DiaryTableSection: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = DiaryDataModel
    
    var identity: Identity {
        return self.items.description
    }
    
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
    
    init(original: DiaryTableSection, items: [DiaryDataModel]) {
        self = original
        self.items = items
    }
}

// MARK: - DiaryViewController DataSource

extension DiaryViewController {
    typealias TableDataSource = RxTableViewSectionedAnimatedDataSource<DiaryTableSection>
    typealias CollectionDataSource = RxCollectionViewSectionedAnimatedDataSource<DiaryTableSection>
    
    var collectionDataSource: CollectionDataSource {
        let dataSource = CollectionDataSource(
            animationConfiguration:
                AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                       reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                       deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
                                      ),
            configureCell: { dataSource, collectionView, indexPath, item in
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConfig.DiaryConfig.collectionCellId, for: indexPath) as? DiaryCollectionCell else { return .init() }
                
//                cell.configureCell()
                
                return cell
            })
        return dataSource
    }
}
