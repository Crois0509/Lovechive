//
//  PlanTableViewDataSource.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import FirebaseFirestore

/// 메인 페이지의 플래너 뷰 SectionModel
struct PlanTableViewSection: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = ScheduleDataModel
    
    var identity: Identity {
        return self.items.description
    }
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    init(original: PlanTableViewSection, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: - MainPageViewController DataSource

extension MainPageViewController {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<PlanTableViewSection>
    
    var dataSource: DataSource {
        let dataSource = DataSource(configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConfig.PlanerView.cellId, for: indexPath) as? PlanViewCell else { return .init() }
            
            cell.configureCell(title: item.title, date: item.date)
            cell.selectionStyle = .none
            
            return cell
            
        })
        
        return dataSource
    }
}
