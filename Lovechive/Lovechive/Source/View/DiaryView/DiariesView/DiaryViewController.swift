//
//  DiaryViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class DiaryViewController: UIViewController {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<DiariesSection>
    
    private let collectionView = DiaryCollectionView()
    private let tableView = DiaryTableView()
    private let infoLabel = UILabel()
    private let addButton = FloatingButton()
    
    private var disposeBag = DisposeBag()
    private var viewModel: DiaryViewModel
    private let fetchTrigger = PublishRelay<Void>()
    private let diaryItemDelete = PublishRelay<IndexPath>()
    fileprivate let updateDiaryData = PublishRelay<Void>()
    
    var collectionDataSource: DataSource {
        let dataSource = DataSource(
            animationConfiguration:
                AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                       reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                       deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
                                      ),
            configureCell: { dataSource, collectionView, indexPath, item in
                
                guard let cell = collectionView.dequeueReusableCell(withIdentifier: AppConfig.DiaryConfig.collectionCellId, for: indexPath) as? DiaryCollectionCell else { return .init() }
                
                cell.configureCell(item)
                cell.selectionStyle = .none
                
                return cell
            
            }, titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].header
                
            }, canEditRowAtIndexPath: { _, _ in true })
        
        return dataSource
    }
    
    private lazy var tableDataSource = DataSource(
        animationConfiguration:
            AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                   reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                   deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
                                  ),
        configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConfig.DiaryConfig.tableCellId, for: indexPath) as? DiaryTableCell else { return .init() }
            
            cell.configureCell(item.createdAt, item.title)
            cell.selectionStyle = .none
            
            if dataSource.sectionModels[indexPath.section].items.count <= 1 {
                cell.containerView.layer.cornerRadius = 16
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                if dataSource.sectionModels[indexPath.section].items.startIndex == indexPath.row {
                    cell.containerView.layer.cornerRadius = 16
                    cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    
                } else if dataSource.sectionModels[indexPath.section].items.count - 1 == indexPath.row {
                    cell.containerView.layer.cornerRadius = 16
                    cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else {
                    cell.containerView.layer.cornerRadius = 0
                }
            }
            
            return cell
            
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].header
            
        }, canEditRowAtIndexPath: { _, _ in true })
    
    init(_ diaryData: DiaryListDataModel) {
        self.viewModel = DiaryViewModel(diaryData)
        super.init(nibName: nil, bundle: nil)
        createdNavigationTitle(diaryData.diaryTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint(Self.self, "deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchTrigger.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

}

// MARK: - UI Setting Method

private extension DiaryViewController {
    
    func setupUI() {
        setupInfoLabel()
        configureSelf()
        setupLayout()
        bind()
        
        let state: String = UserDefaults.standard.string(forKey: "정렬 방법") == nil ? "List" : UserDefaults.standard.string(forKey: "정렬 방법")!
        if state == "List" {
            changeCurrentState(.table)
        } else {
            changeCurrentState(.collection)
        }
    }
    
    func configureSelf() {
        view.backgroundColor = .Personal.backgroundPink
        navigationItem.title = ""
        navigationController?.navigationBar.tintColor = .Personal.deepPink
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .Icon.naviSettings, style: .done, target: self, action: nil)
        [tableView, collectionView, infoLabel, addButton].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(30)
            $0.width.height.equalTo(72)
        }
    }
    
    func setupInfoLabel() {
        infoLabel.text = "아직 추가된 일기가 없습니다."
        infoLabel.font = .myoyaFont(24)
        infoLabel.textColor = .Gray.unSelected
        infoLabel.numberOfLines = 2
        infoLabel.textAlignment = .center
        infoLabel.backgroundColor = .clear
    }
    
    func createdNavigationTitle(_ title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .Personal.highlightPink
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        
        navigationItem.titleView = titleLabel
    }
    
    func changeCurrentState(_ type: DiaryState) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve) {
            switch type {
            case .table:
                self.collectionView.alpha = 0
                self.view.insertSubview(self.tableView, aboveSubview: self.collectionView)
                self.tableView.alpha = 1
            case .collection:
                self.tableView.alpha = 0
                self.view.insertSubview(self.collectionView, aboveSubview: self.tableView)
                self.collectionView.alpha = 1
            }
        }
    }
    
    func pushDiariesView(type: DiaryViewState, id: String) -> Observable<Void> {
        guard let titleView = navigationItem.titleView as? UILabel,
              let title = titleView.text
        else { return .just(()) }
        
        let editDiaryVC = EditDiaryViewController(title, type, id)
        navigationController?.pushViewController(editDiaryVC, animated: true)
        
        let dismissSignal = editDiaryVC.rx.deallocated
        
        return editDiaryVC.rx.diarySavedIsSuccess
            .take(until: dismissSignal)
            .do(onDispose: { [weak editDiaryVC] in
                print("\(editDiaryVC?.description ?? "EditDiaryVC") deallocated")
            })
    }
    
    func bind() {
        let input = DiaryViewModel.Input(fetchTrigger: fetchTrigger,
                                         settingButtonTapped: navigationItem.rightBarButtonItem!.rx.tap,
                                         addButtonTapped: addButton.rx.tap,
                                         tableItemSelected: tableView.tableView.rx.itemSelected,
                                         collectionItemSelected: collectionView.collectionView.rx.itemSelected,
                                         diaryItemDelete: diaryItemDelete
        )
        
        let output = viewModel.transform(input: input)
        
        tableView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        collectionView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        output.sections
            .bind(to: tableView.tableView.rx.items(dataSource: tableDataSource))
            .disposed(by: disposeBag)
        
        output.sections
            .bind(to: collectionView.collectionView.rx.items(dataSource: collectionDataSource))
            .disposed(by: disposeBag)
        
        output.sections
            .asDriver(onErrorJustReturn: [])
            .drive { [weak self] data in
                guard let self else { return }
                let isEmpty = data.isEmpty
                self.infoLabel.isHidden = !isEmpty
                self.tableView.isHidden = isEmpty
                self.collectionView.isHidden = isEmpty
                self.updateDiaryData.accept(())
            }
            .disposed(by: disposeBag)
        
        output.pushDiaryPage
            .withUnretained(self)
            .flatMap { owner, data in
                debugPrint("다이어리 선택됨", data.data.title)
                return owner.pushDiariesView(type: .view(data: data.data), id: data.id)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] _ in
                self?.fetchTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        output.pushNewDiary
            .withUnretained(self)
            .flatMap { owner, id in
                return owner.pushDiariesView(type: .edit(data: nil), id: id)
            }
            .asSignal(onErrorSignalWith: .empty())
            .emit { [weak self] _ in
                self?.fetchTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        output.sortMethodRelay
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, state in
                owner.changeCurrentState(state)
            }
            .disposed(by: disposeBag)
        
        output.fetchDiaryTitle
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, title in
                owner.createdNavigationTitle(title)
                owner.updateDiaryData.accept(())
            }
            .disposed(by: disposeBag)
        
        output.dismissDiaryView
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.updateDiaryData.accept(())
                owner.disposeBag = DisposeBag()
                owner.navigationController?.popViewController(animated: true)
                owner.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
    }
}

extension DiaryViewController: UITableViewDelegate {
    
    // 테이블뷰 헤더 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard !tableDataSource.sectionModels.isEmpty else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.backgroundColor = .clear
        label.text = tableDataSource.sectionModels[section].header
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .Personal.highlightPink
        label.numberOfLines = 1
        label.textAlignment = .left
        
        headerView.addSubview(label)
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview()
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // 모든 셀에서 삭제 가능하도록 설정
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self = self else { return }
            
            self.diaryItemDelete.accept(indexPath)
            completion(true) // ✅ 삭제 후 애니메이션 적용
        }
        
        deleteAction.backgroundColor = .red // 버튼 색상
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: DiaryViewController {
    var updateDiaryData: PublishRelay<Void> {
        base.updateDiaryData
    }
}
