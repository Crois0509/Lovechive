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

final class DiaryViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    private let fetchTrigger = PublishRelay<Void>()
    
    private let viewModel = DiaryListViewModel()
    
    private let diaryListView = DiaryListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = diaryListView
        bind()
        fetchTrigger.accept(())
    }
    
}

// MARK: - UI Setting Method

private extension DiaryViewController {
    
    func bind() {
        let input = DiaryListViewModel.Input(fetchTrigger: fetchTrigger,
                                             itemSelected: diaryListView.collectionView.rx.itemSelected,
                                             diaryAddButtonTapped: diaryListView.rx.diaryAddButtonTapped
        )
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .bind(to: diaryListView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.sections
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] items in
                let itemIsEmpty = items.isEmpty
                self?.diaryListView.setInfoLabelHidden(itemIsEmpty)
            }
            .disposed(by: disposeBag)
        
        output.pushDiaryView
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, item in
                debugPrint("\(item) 선택 됨")
            }
            .disposed(by: disposeBag)
    }
    
}
