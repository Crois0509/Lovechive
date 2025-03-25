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
        let settingButtonTapped: ControlEvent<Void>
        let addButtonTapped: ControlEvent<Void>
        let tableItemSelected: ControlEvent<IndexPath>
        let collectionItemSelected: ControlEvent<IndexPath>
    }

    struct Output {
        let sections: BehaviorRelay<[DiariesSection]>
        let pushDiaryPage: PublishRelay<(data: DiaryDataModel, id: String)>
        let sortMethodRelay: BehaviorRelay<DiaryState>
        let fetchDiaryTitle: PublishRelay<String>
        let pushNewDiary: PublishRelay<String>
    }
    
    private var disposeBag = DisposeBag()
    private var diaryId: String
    private var diaryData: DiaryListDataModel
    
    private let sections = BehaviorRelay<[DiariesSection]>(value: [])
    private let pushDiaryPage = PublishRelay<(data: DiaryDataModel, id: String)>()
    private let sortMethodRelay = BehaviorRelay<DiaryState>(value: .table)
    private let fetchDiaryTitle = PublishRelay<String>()
    private let pushNewDiary = PublishRelay<String>()
    
    init(_ diaryData: DiaryListDataModel) {
        self.diaryId = diaryData.diaryId
        self.diaryData = diaryData
    }
    
    func transform(input: Input) -> Output {
        
        input.fetchTrigger
            .withUnretained(self)
            .flatMap { owner, _ -> Single<[QueryDocumentSnapshot]> in
                owner.fetchDiaryData(owner.diaryId)
            }
            .map { [weak self] query -> [DiariesSection] in
                guard let self else { return [] }
                return self.mappingQueryDataToDiaryData(query)
            }
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] data in
                self?.sections.accept(data)
            }
            .disposed(by: disposeBag)
        
        input.tableItemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath -> DiaryDataModel? in
                owner.searchItem(indexPath)
            }
            .compactMap { [weak self] data in
                return (data, self!.diaryId)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] data in
                self?.pushDiaryPage.accept(data)
            }
            .disposed(by: disposeBag)
        
        input.collectionItemSelected
            .withUnretained(self)
            .compactMap { owner, indexPath -> DiaryDataModel? in
                owner.searchItem(indexPath)
            }
            .compactMap { [weak self] data in
                return (data, self!.diaryId)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] data in
                self?.pushDiaryPage.accept(data)
            }
            .disposed(by: disposeBag)
        
        input.settingButtonTapped
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.showSettingAlertView()
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] _ in
                self?.dismissSettingAlertView()
            }
            .disposed(by: disposeBag)
        
        input.addButtonTapped
            .withUnretained(self)
            .map { owner, _ -> String in owner.diaryId }
            .bind(to: pushNewDiary)
            .disposed(by: disposeBag)
        
        return Output(sections: sections,
                      pushDiaryPage: pushDiaryPage,
                      sortMethodRelay: sortMethodRelay,
                      fetchDiaryTitle: fetchDiaryTitle,
                      pushNewDiary: pushNewDiary
        )
    }
}

// MARK: - DiaryViewModel Private Method

private extension DiaryViewModel {
    
    /// Query 데이터를 DiaryDataModel 타입으로 가공하는 메소드
    /// - Parameter data: Query 데이터
    /// - Returns: 변환된 DiaryDataModel 데이터 배열
    func mappingQueryDataToDiaryData(_ data: [QueryDocumentSnapshot]) -> [DiariesSection] {
        let data = data.map {
            DiaryDataModel(id: $0.data()[AppConfig.DiariesModel.id] as? String ?? "",
                           title: $0.data()[AppConfig.DiariesModel.title] as? String ?? "",
                           content: $0.data()[AppConfig.DiariesModel.content] as? String ?? "",
                           image: $0.data()[AppConfig.DiariesModel.image] as? String ?? "",
                           createdAt: ($0.data()[AppConfig.DiariesModel.createdAt] as? Timestamp)?.dateValue() ?? Date(),
                           createdBy: $0.data()[AppConfig.DiariesModel.createdBy] as? String ?? "")
        }.sorted(by: {
            let state: String = UserDefaults.standard.string(forKey: "정렬 순서") == nil ? "최신순" : UserDefaults.standard.string(forKey: "정렬 순서")!
            
            if state == "최신순" {
                return $0.createdAt > $1.createdAt
            } else {
                return $0.createdAt < $1.createdAt
            }
        })
        
        let groupingData = Dictionary(grouping: data) { data in
            data.createdAt.formattedDateToString(.yearMonth)
        }
        
        let section = groupingData.map { data in
            DiariesSection(header: data.key, items: data.value)
        }.sorted {
            let state: String = UserDefaults.standard.string(forKey: "정렬 순서") == nil ? "최신순" : UserDefaults.standard.string(forKey: "정렬 순서")!
            
            if state == "최신순" {
                return $0.header.formattedStringToDate(.yearMonth) > $1.header.formattedStringToDate(.yearMonth)
            } else {
                return $0.header.formattedStringToDate(.yearMonth) < $1.header.formattedStringToDate(.yearMonth)
            }
        }
        
        return section
    }
    
    func mappingQueryDataToDiaryListDataModel(_ data: [QueryDocumentSnapshot]) -> DiaryListDataModel? {
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
        }.filter {
            $0.diaryId == self.diaryId
        }.first
        
        return data
    }
    
    func searchItem(_ indexPath: IndexPath) -> DiaryDataModel? {
        guard indexPath.section < sections.value.count,
              indexPath.row < sections.value[indexPath.section].items.count
        else { return nil }
        
        let section = sections.value[indexPath.section]
        let item = section.items[indexPath.row]
        
        return item
    }
    
    func showSettingAlertView() -> Observable<Void> {
        guard let vc = AppHelpers.getTopViewController(),
              vc.children.last as? DiarySettingAlertViewController == nil
        else { return .just(()) }
        
        let alert = DiarySettingAlertViewController()
        
        vc.addChild(alert)
        vc.view.addSubview(alert.view)
        alert.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        alert.didMove(toParent: vc)
        
        vc.navigationItem.rightBarButtonItem?.isEnabled = false
        vc.navigationItem.hidesBackButton = true
        
        let dismissSignal = alert.rx.deallocated
        
        alert.rx.changedSortValue.take(until: dismissSignal)
            .compactMap { menu -> DiaryState? in
                if menu == "List" {
                    return .table
                } else if menu == "Collection" {
                    return .collection
                } else {
                    return nil
                }
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] state in
                self?.sortMethodRelay.accept(state)
            }
            .disposed(by: disposeBag)
        
        alert.rx.changedSortOrderValue.take(until: dismissSignal)
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, sort in
                owner.sortedSection(sort)
            }
            .disposed(by: disposeBag)
        
        alert.rx.editButtonTapped.take(until: dismissSignal)
            .withUnretained(self)
            .flatMap { owner, _ -> PublishRelay<Bool> in
                owner.dismissSettingAlertView()
                
                return owner.showAlertView(type: .editDiary(data: owner.diaryData))
            }
            .flatMap { [weak self] isSuccess -> Single<[QueryDocumentSnapshot]> in
                guard let self else { return .just([]) }
                
                if isSuccess {
                    self.dismissAlertView() 
                    return self.fetchData(.diary(id: self.diaryId))
                } else {
                    self.dismissAlertView()
                    return .just([])
                }
            }
            .compactMap { [weak self] query -> DiaryListDataModel? in
                self?.mappingQueryDataToDiaryListDataModel(query)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] data in
                debugPrint("✅ 다이어리 데이터 편집 성공")
                self?.fetchDiaryTitle.accept(data.diaryTitle)
            }
            .disposed(by: disposeBag)
        
        return alert.rx.cancelButtonTapped.take(until: dismissSignal).asObservable()
    }
    
    func dismissSettingAlertView() {
        guard let topVC = AppHelpers.getTopViewController() as? DiaryViewController,
              let alert = topVC.children.last as? DiarySettingAlertViewController
        else { return }
        
        alert.dismissSelf {
            alert.view.snp.removeConstraints()
            alert.view.removeFromSuperview()
            alert.removeFromParent()
        }
        
        topVC.navigationItem.rightBarButtonItem?.isEnabled = true
        topVC.navigationItem.hidesBackButton = false
    }
    
    func sortedSection(_ option: String) {
        let section = sections.value
        
        if option == "최신순" {
            let sortedSection = section.map {
                let items = $0.items.sorted(by: { $0.createdAt > $1.createdAt })
                return DiariesSection(header: $0.header, items: items)
            }.sorted {
                $0.header.formattedStringToDate(.yearMonth) > $1.header.formattedStringToDate(.yearMonth)
            }
            
            sections.accept(sortedSection)
                        
        } else if option == "오래된순" {
            let sortedSection = section.map {
                let items = $0.items.sorted(by: { $0.createdAt < $1.createdAt })
                return DiariesSection(header: $0.header, items: items)
            }.sorted {
                $0.header.formattedStringToDate(.yearMonth) < $1.header.formattedStringToDate(.yearMonth)
            }
            
            sections.accept(sortedSection)
            
        }
    }
    
}
