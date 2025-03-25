//
//  DiarySettingAlertViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DiarySettingAlertViewController: UIViewController {
        
    fileprivate let alertView = DiarySettingAlertView()
    private let dim = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showAlertView()
    }
    
    func dismissSelf(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            self.dim.alpha = 0
            self.alertView.frame.origin.y = self.view.frame.maxY + 50
        } completion: { _ in
            completion()
        }
    }
    
}

// MARK: - UI Setting Method

private extension DiarySettingAlertViewController {
    
    func setupUI() {
        setupDim()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        view.backgroundColor = .clear
        [dim, alertView].forEach {
            view.addSubview($0)
        }
    }
    
    func setupLayout() {
        dim.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        alertView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        alertView.frame.origin.y = view.frame.maxY + 50
    }
    
    func setupDim() {
        dim.backgroundColor = .black
        dim.alpha = 0
    }
    
    func showAlertView() {
        UIView.animate(withDuration: 0.3) {
            self.dim.alpha = 0.25
            self.alertView.frame.origin.y = self.view.frame.midY
        }
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: DiarySettingAlertViewController {
    var cancelButtonTapped: ControlEvent<Void> {
        base.alertView.rx.cancelButtonTapped
    }
    
    var editButtonTapped: ControlEvent<Void> {
        base.alertView.rx.editButtonTapped
    }
    
    var deleteButtonTapped: ControlEvent<Void> {
        base.alertView.rx.deleteButtonTapped
    }
    
    var changedSortValue: BehaviorRelay<String> {
        base.alertView.rx.changedSortMethod
    }
    
    var changedSortOrderValue: BehaviorRelay<String> {
        base.alertView.rx.changedSortOrder
    }

}
