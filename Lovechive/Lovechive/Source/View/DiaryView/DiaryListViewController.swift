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
    private let fetchTrigger = PublishRelay<Void>()
    
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
            .emit { owner, diaryInfo in
                debugPrint("\(diaryInfo.title) 선택 됨")
                let diaryVC = DiaryViewController(diaryInfo.title, diaryInfo.id)
                owner.navigationController?.pushViewController(diaryVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
