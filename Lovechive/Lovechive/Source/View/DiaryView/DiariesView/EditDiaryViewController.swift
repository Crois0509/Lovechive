//
//  EditDiaryViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/24/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class EditDiaryViewController: UIViewController {
    
    private let diaryView = EditDiaryView()
    
    init(_ title: String?) {
        super.init(nibName: nil, bundle: nil)
        
        createdNavigationTitle(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    func configureDiary(_ data: DiaryDataModel) {
        diaryView.configureDiary(data)
    }
    
}

// MARK: - UI Setting Method

private extension EditDiaryViewController {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        navigationController?.navigationBar.tintColor = .Personal.deepPink
        view.backgroundColor = .Personal.backgroundPink
        view.addSubview(diaryView)
    }
    
    func setupLayout() {
        diaryView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(440)
        }
    }
    
    func createdNavigationTitle(_ title: String?) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .Personal.highlightPink
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        
        navigationItem.titleView = titleLabel
    }
}
