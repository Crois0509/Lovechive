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
        let latestDiaryRelay: PublishRelay<DiaryDataModel>
    }
    
    private var disposeBag = DisposeBag()
    
    private let sections = BehaviorRelay<[PlanTableViewSection]>(value: [])
    private let latestDiaryRelay = PublishRelay<DiaryDataModel>()
    
    func transform(input: Input) -> Output {
        input.fetchTrigger
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, _ in
                owner.fetchSectionData()
            }.disposed(by: disposeBag)
        
        input.fetchTrigger
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, _ in
                owner.fetchDiaryData()
            }.disposed(by: disposeBag)
        
        return Output(sections: sections,
                      latestDiaryRelay: latestDiaryRelay
        )
    }
    
    private func fetchSectionData() {
        FirestoreManager.shared.readFromFirestore(type: .schedule(id: ""), { [weak self] query in
            guard let query, let self else { return }
            
            let data = query.filter {
                let date = ($0.data()["date"] as? Timestamp)?.dateValue() ?? Date()
                
                return Date() <= date
            }.map {
                ScheduleDataModel(
                    id: $0.data()["id"] as? String ?? "",
                    title: $0.data()["title"] as? String ?? "",
                    coupleId: $0.data()["coupleId"] as? String ?? "",
                    date: ($0.data()["date"] as? Timestamp)?.dateValue() ?? Date(),
                    createdBy: $0.data()["createdBy"] as? String ?? ""
                )
            }
            
            let sortedData = Array(data.sorted(by: {
                $0.date < $1.date
            }).prefix(3))
            
            let section = PlanTableViewSection(items: sortedData)
            self.sections.accept([section])
        })
    }
    
    private func fetchDiaryData() {
        FirestoreManager.shared.readFromFirestore(type: .diary(id: "")) { [weak self] query in
            guard let query, let self else { return }
            
            let data = query.map {
                DiaryDataModel(id: $0.data()["id"] as? String ?? "",
                               author: $0.data()["author"] as? String ?? "",
                               coupleId: $0.data()["coupleId"] as? String ?? "",
                               content: $0.data()["content"] as? String ?? "",
                               image: $0.data()["image"] as? String ?? "",
                               createdAt: ($0.data()["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }.sorted(by: {
                $0.createdAt < $1.createdAt
            })
            
            guard let latestData = data.last else { return }
            self.latestDiaryRelay.accept(latestData)
        }
    }
    
    private func loadImageFromLocalPath(path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            return image
        } else {
            print("❌ 이미지 로드 실패")
            return nil
        }
    }
}
