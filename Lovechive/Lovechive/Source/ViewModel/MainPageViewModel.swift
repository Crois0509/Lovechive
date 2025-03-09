//
//  MainPageViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

final class MainPageViewModel: ViewModelType {
    struct Input {
        let fetchTrigger: PublishRelay<Void>
    }
    
    struct Output {
        let sections: BehaviorRelay<[PlanTableViewSection]>
    }
    
    private var disposeBag = DisposeBag()
    
    private let sections = BehaviorRelay<[PlanTableViewSection]>(value: [])
    
    func transform(input: Input) -> Output {
        input.fetchTrigger
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, _ in
                owner.fetchData()
            }.disposed(by: disposeBag)
        
        return Output(sections: sections)
    }
    
    private func fetchData() {
        FirestoreManager.shared.readFromFirestore(type: .schedule, { query in
            guard let query else { return }
            
            let data = query.filter {
                let date = ($0.data()["date"] as? Timestamp)?.dateValue() ?? Date()
                
                return Date() <= date
            }.map {
                ScheduleDataModel(
                    title: $0.data()["title"] as? String ?? "",
                    coupleId: $0.data()["coupleId"] as? String ?? "",
                    date: ($0.data()["date"] as? Timestamp)?.dateValue() ?? Date(),
                    createdBy: $0.data()["createdBy"] as? String ?? ""
                )
            }
            
            let result = Array(data.sorted(by: {
                $0.date < $1.date
            }).prefix(3))
            
            let section = PlanTableViewSection(items: result)
            self.sections.accept([section])
        })
    }
}
