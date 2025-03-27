//
//  DiaryViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DiaryListViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    fileprivate let fetchTrigger = PublishRelay<Void>()
    
    private let viewModel = DiaryListViewModel()
    
    private let diaryListView = DiaryListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        view = diaryListView
        bind()
        fetchTrigger.accept(())
    }
    
}

// MARK: - UI Setting Method

private extension DiaryListViewController {
    
    func pushDiariesView(_ data: DiaryListDataModel) -> Observable<Void> {
        let diaryVC = DiaryViewController(data)
        let dismissSignal = diaryVC.rx.deallocated
        
        navigationController?.pushViewController(diaryVC, animated: true)
        
        return diaryVC.rx.updateDiaryData
            .take(until: dismissSignal)
            .do(onDispose: { [weak diaryVC] in
                debugPrint("\(diaryVC?.description ?? "DiaryViewController")", "deallocated")
            })
    }
    
    func bind() {
        let input = DiaryListViewModel.Input(fetchTrigger: fetchTrigger,
                                             itemSelected: diaryListView.collectionView.rx.itemSelected,
                                             diaryAddButtonTapped: diaryListView.rx.diaryAddButtonTapped
        )
        
        let output: DiaryListViewModel.Output
        
        if UserDefaults.standard.bool(forKey: AppConfig.UserDefaultsConfig.guestMode) == true {
            output = viewModel.transformToGuestMode(input: input)
        } else {
            output = viewModel.transform(input: input)
        }
        
        output.sections
            .bind(to: diaryListView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.sections
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive { owner, items in
                let itemIsEmpty = items.isEmpty
                debugPrint(itemIsEmpty, items.count)
                owner.diaryListView.setInfoLabelHidden(itemIsEmpty)
            }
            .disposed(by: disposeBag)
        
        output.pushDiaryView
            .withUnretained(self)
            .flatMap { owner, diaryInfo in
                debugPrint("\(diaryInfo.diaryTitle) 선택 됨")
                return owner.pushDiariesView(diaryInfo)
            }
            .asSignal(onErrorJustReturn: ())
            .emit { [weak self] _ in
                self?.fetchTrigger.accept(())
            }
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: DiaryListViewController {
    var diaryDataRelay: PublishRelay<Void> {
        base.fetchTrigger
    }
}
