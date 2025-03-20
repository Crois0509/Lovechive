//
//  DiaryViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

final class DiaryViewModel: ViewModelMethodManager, ViewModelType {
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
    }

    struct Output {
        let sections: BehaviorRelay<[DiaryTableSection]>
    }
    
    private var disposeBag = DisposeBag()
    private var diaryId: String
    
    private let sections = BehaviorRelay<[DiaryTableSection]>(value: [])
    
    init(_ diaryId: String) {
        self.diaryId = diaryId
    }
    
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> Single<[QueryDocumentSnapshot]> in
                owner.fetchDiaryData(owner.diaryId)
            }
            .map { [weak self] query -> [DiaryTableSection] in
                guard let self else { return [] }
                return self.mappingQueryDataToDiaryData(query)
            }
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] data in
                self?.sections.accept(data)
            }
            .disposed(by: disposeBag)
        
        return Output(sections: sections)
    }
}

// MARK: - DiaryViewModel Private Method

private extension DiaryViewModel {
    
    /// Query 데이터를 DiaryDataModel 타입으로 가공하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 DiaryDataModel 데이터 배열
    func mappingQueryDataToDiaryData(_ data: [QueryDocumentSnapshot]) -> [DiaryTableSection] {
        let data = data.map {
            DiaryDataModel(id: $0.data()[AppConfig.DiariesModel.id] as? String ?? "",
                           title: $0.data()[AppConfig.DiariesModel.title] as? String ?? "",
                           content: $0.data()[AppConfig.DiariesModel.content] as? String ?? "",
                           image: $0.data()[AppConfig.DiariesModel.image] as? String ?? "",
                           createdAt: ($0.data()[AppConfig.DiariesModel.createdAt] as? Timestamp)?.dateValue() ?? Date(),
                           createdBy: $0.data()[AppConfig.DiariesModel.createdBy] as? String ?? "")
        }.sorted(by: {
            $0.createdAt > $1.createdAt
        })
        
        let groupingData = Dictionary(grouping: data) { data in
            data.createdAt.formattedDateToString(.yearMonth)
        }
        
        let section = groupingData.map { data in
            DiaryTableSection(header: data.key, items: data.value)
        }.sorted {
            $0.header.formattedStringToDate(.yearMonth) > $1.header.formattedStringToDate(.yearMonth)
        }
        
        return section
    }
    
}
