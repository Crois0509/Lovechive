//
//  LovechiveAlertViewController.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 커스텀 Alert 뷰 컨트롤러
final class LovechiveAlertViewController: UIViewController {
    
    // MARK: - Rx Properties
    
    private var disposeBag = DisposeBag()
    fileprivate let dataSavedRelay = PublishRelay<Void>()
    
    // MARK: - Properties
    
    private let viewModel: LovechiveAlertViewModel
    
    // MARK: - UI Components
    
    private(set) var alertView: LovechiveAlertView
    private let dim = UIView()
    
    // MARK: - Initializer
    
    init(type: AlertTypes) {
        alertView = .init(type: type)
        viewModel = .init(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showAlertView()
    }
    
    // 키보드 내리기 설정
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    /// LovechiveAlertView를 화면에서 없애는 메소드
    /// - Parameter completion: 뷰가 화면에서 없어진 뒤에 실행할 동작
    func dismissSelf(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            self.dim.alpha = 0
            self.alertView.frame.origin.y = self.view.frame.maxY + 50
            self.view.endEditing(true)
        } completion: { _ in
            completion()
        }
    }
}

// MARK: - UI Setting Method

private extension LovechiveAlertViewController {
    
    func setupUI() {
        setupDim()
        configureSelf()
        setupLayout()
        bind()
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
            $0.center.equalToSuperview()
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
        } completion: { _ in
            self.alertView.showKeyboard()
        }
    }
    
    func bind() {
        let input = LovechiveAlertViewModel.Input(cancelButtonTapped: alertView.rx.cancelButtonTapped,
                                                  activeButtonTapped: alertView.rx.activeButtonTapped,
                                                  scheduleTimeRelay: alertView.rx.firstSectionTextFieldRelay,
                                                  scheduleTitleRelay: alertView.rx.secondSectionTextFieldRelay
        )
        
        let output = viewModel.transform(input: input)
        
        alertView.rx.layoutSubviewsEvent
            .withUnretained(self)
            .asSignal(onErrorSignalWith: .empty())
            .emit { owner, _ in
                owner.alertView.updateSectionViewSize()
            }
            .disposed(by: disposeBag)
        
        output.dataSaved
            .bind(to: dataSavedRelay)
            .disposed(by: disposeBag)
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: LovechiveAlertViewController {
    /// 데이터 저장이 완료되면 이벤트를 방출하는 옵저버블
    var dataSavedRelay: PublishRelay<Void> {
        base.dataSavedRelay
    }
}
