//
//  DiaryListSectionModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct DiaryListSection: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = DiaryListDataModel
    
    var identity: Identity {
        return self.items.description
    }
    
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    init(original: DiaryListSection, items: [DiaryListDataModel]) {
        self = original
        self.items = items
    }
}

// MARK: - DiaryViewController DataSource

extension DiaryViewController {
    typealias DataSource = RxCollectionViewSectionedAnimatedDataSource<DiaryListSection>
    
    var dataSource: DataSource {
        let dataSource = DataSource(animationConfiguration:
                                        AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                                               reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                                               deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
            ), configureCell: { dataSource, collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppConfig.DiaryConfig.cellId, for: indexPath) as? DiaryListCell else { return .init() }
            
            cell.configureCell(item)
            
            return cell
        })
        
        return dataSource
    }
}
