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
struct ScheduleModelSection: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = ScheduleDataModel
    
    var identity: Identity {
        return self.items.description
    }
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
    
    init(original: ScheduleModelSection, items: [Item]) {
        self = original
        self.items = items
    }
}

// MARK: - Schedule DataSource Protocol

/// Schedule 타입의 데이터소스 공용 프로토콜
protocol ScheduleTableSectionConfigurable {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<ScheduleModelSection>
    var dataSource: DataSource { get }
}

// MARK: - MainPageViewController DataSource

extension MainPageViewController: ScheduleTableSectionConfigurable {
    var dataSource: DataSource {
        let dataSource = DataSource(animationConfiguration:
                                        AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                                               reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                                               deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
            ), configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConfig.PlanerView.cellId, for: indexPath) as? PlanViewCell else { return .init() }
            
            cell.configureCell(title: item.title, date: item.date)
            cell.selectionStyle = .none
            
            return cell
            
        })
        
        return dataSource
    }
}

// MARK: - CalendarViewController DataSource

extension CalendarViewController: ScheduleTableSectionConfigurable {
    var dataSource: DataSource {
        let dataSource = DataSource(animationConfiguration:
                                        AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                                               reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                                               deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
            ), configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConfig.CalendarViewConfig.cellId, for: indexPath) as? ScheduleViewCell else { return .init() }
            
            cell.configureCell(time: item.date, title: item.title)
            cell.selectionStyle = .none
            
            return cell
            
        }, canEditRowAtIndexPath: { _, _ in true })
        
        return dataSource
    }
}
