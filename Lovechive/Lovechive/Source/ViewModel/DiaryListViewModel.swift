//
//  DiaryListViewModel.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FirebaseFirestore

final class DiaryListViewModel: ViewModelMethodManager, ViewModelType {
    
    struct Input {
        let fetchTrigger: PublishRelay<Void>
        let itemSelected: ControlEvent<IndexPath>
        let diaryAddButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let sections: BehaviorRelay<[DiaryListSection]>
        let pushDiaryView: PublishRelay<[DiaryDataModel]>
    }
    
    private var disposeBag = DisposeBag()
    
    private let sections = BehaviorRelay<[DiaryListSection]>(value: [])
    private let pushDiaryView = PublishRelay<[DiaryDataModel]>()
    private let itemIndexRelay = PublishRelay<Int>()
    
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> Single<[QueryDocumentSnapshot]> in
                owner.fetchData(.diary(id: ""))
            }
            .map { [weak self] query -> DiaryListSection in
                guard let self else { return DiaryListSection(items: []) }
                return self.mappingQueryDataToDiaryListData(query)
            }
            .asDriver(onErrorJustReturn: DiaryListSection(items: []))
            .drive { [weak self] data in
                self?.sections.accept([data])
            }
            .disposed(by: disposeBag)
        
        input.itemSelected
            .compactMap { $0.item }
            .bind(to: itemIndexRelay)
            .disposed(by: disposeBag)
        
        itemIndexRelay
            .distinctUntilChanged()
            .withUnretained(self)
            .compactMap { owner, index -> String? in
                return owner.searchItemId(index)
            }
            .flatMap { [weak self] id -> Single<[QueryDocumentSnapshot]> in
                guard let self else { return .just([]) }
                return self.fetchDiaryData(id)
            }
            .compactMap { [weak self] query -> [DiaryDataModel]? in
                self?.mappingQueryDataToDiaryData(query)
            }
            .asSignal(onErrorJustReturn: [])
            .emit { [weak self] data in
                self?.pushDiaryView.accept(data)
            }
            .disposed(by: disposeBag)
        
        input.diaryAddButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showAlertView(type: .newDiary)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { isSuccess in
                if isSuccess {
                    input.fetchTrigger.accept(())
                } else {
                    debugPrint("❌ 일정 추가 실패")
                }
            }
            .disposed(by: disposeBag)
        
        return Output(sections: sections,
                      pushDiaryView: pushDiaryView)
    }
}

private extension DiaryListViewModel {
    
    /// Query 데이터를 DiaryListSection 타입으로 가공하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 DiaryListSection 데이터 배열
    func mappingQueryDataToDiaryListData(_ data: [QueryDocumentSnapshot]) -> DiaryListSection {
        let data = data.compactMap { data -> DiaryListDataModel? in
            let item = DiaryListDataModel(coupleId: data.data()[AppConfig.DiariesModel.coupleId] as? String ?? "",
                                          diaryId: data.data()[AppConfig.DiariesModel.diaryId] as? String ?? "",
                                          diaryTitle: data.data()[AppConfig.DiariesModel.diaryTitle] as? String ?? "",
                                          diarySubTitle: data.data()[AppConfig.DiariesModel.diarySubTitle] as? String ?? "",
                                          diaryColor: data.data()[AppConfig.DiariesModel.diaryColor] as? String ?? "",
                                          diaryCreatedAt: (data.data()[AppConfig.DiariesModel.diaryCreatedAt] as? Timestamp)?.dateValue() ?? Date())
            
            if item.diaryId == "" {
                return nil
            } else {
                return item
            }
        }.sorted(by: {
            $0.diaryCreatedAt > $1.diaryCreatedAt
        })
        
        let section = DiaryListSection(items: data)
        
        return section
    }
    
    /// Query 데이터를 DiaryDataModel 타입으로 가공하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 DiaryDataModel 데이터 배열
    func mappingQueryDataToDiaryData(_ data: [QueryDocumentSnapshot]) -> [DiaryDataModel] {
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
        
        return data
    }
    
    func searchItemId(_ index: Int) -> String? {
        guard let items = sections.value.first?.items,
              index < items.count
        else { return nil }
        
        let item = items[index]
        
        return item.diaryId
    }
    
}
