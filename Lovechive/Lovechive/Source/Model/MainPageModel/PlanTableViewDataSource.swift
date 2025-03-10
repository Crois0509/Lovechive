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

extension MainPageViewController {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<PlanTableViewSection>
    
    var dataSource: DataSource {
        let dataSource = DataSource(configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanViewCell.id, for: indexPath) as? PlanViewCell else { return .init() }
            
            cell.configureCell(title: item.title, date: item.date)
            cell.selectionStyle = .none
            
            return cell
            
        })
        
        return dataSource
    }
}
