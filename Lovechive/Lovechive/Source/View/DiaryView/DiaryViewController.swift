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
    
    private let tableView = DiaryTableView()
    private let addButton = FloatingButton()
    
    private var disposeBag = DisposeBag()
    private var viewModel: DiaryViewModel
    private let fetchTrigger = PublishRelay<Void>()
    
    private lazy var tableDataSource = TableDataSource(
        animationConfiguration:
            AnimationConfiguration(insertAnimation: .fade,  // 삽입 시 애니메이션
                                   reloadAnimation: .fade,  // 변경 시 애니메이션 없음
                                   deleteAnimation: .fade   // 삭제 시 왼쪽으로 사라짐
                                  ),
        configureCell: { dataSource, tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppConfig.DiaryConfig.tableCellId, for: indexPath) as? DiaryTableCell else { return .init() }
            
            cell.configureCell(item.createdAt, item.title)
            cell.selectionStyle = .none
            
            if dataSource.sectionModels[indexPath.section].items.count == 1 {
                cell.containerView.layer.cornerRadius = 16
            } else {
                if dataSource.sectionModels[indexPath.section].items.startIndex == indexPath.row {
                    cell.containerView.layer.cornerRadius = 16
                    cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    
                } else if dataSource.sectionModels[indexPath.section].items.count - 1 == indexPath.row {
                    cell.containerView.layer.cornerRadius = 16
                    cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                }
            }
            
            return cell
            
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].header
        })
    
    init(_ title: String, _ diaryId: String) {
        self.viewModel = DiaryViewModel(diaryId)
        super.init(nibName: nil, bundle: nil)
        createdNavigationTitle(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        setupNavigationRightButton()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        view.backgroundColor = .Personal.backgroundPink
        navigationController?.navigationBar.tintColor = .Personal.deepPink
        [tableView, addButton].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(30)
            $0.width.height.equalTo(72)
        }
    }
    
    func setupNavigationRightButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .Icon.naviSettings, style: .done, target: self, action: nil)
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
    
    func bind() {
        let input = DiaryViewModel.Input(fetchTrigger: fetchTrigger)
        
        let output = viewModel.transform(input: input)
        
        tableView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        output.sections
            .bind(to: tableView.tableView.rx.items(dataSource: tableDataSource))
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
    
}
