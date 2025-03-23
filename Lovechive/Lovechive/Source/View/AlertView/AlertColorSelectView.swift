//
//  AlertColorSelectView.swift
//  Lovechive
//
//  Created by 장상경 on 3/19/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AlertColorSelectView: UIView {
    
    private let colorStackView = UIStackView()
    
    private var disposeBag = DisposeBag()
    fileprivate let colorButtonTapped = BehaviorRelay<Int>(value: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureColor(_ colorName: String) {
        let index = AlertColorSetModel.allCases.enumerated().map { index, model in
            if model.sendColorName == colorName {
                return index
            } else {
                return -1
            }
        }.filter { $0 != -1 }.first ?? 0
        
        colorButtonTapped.accept(index)
    }
}

// MARK: - UI Setting Method

private extension AlertColorSelectView {
    
    func setupUI() {
        setupStackView()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        addSubview(colorStackView)
    }
    
    func setupLayout() {
        colorStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(32)
        }
    }
    
    func setupStackView() {
        colorStackView.axis = .horizontal
        colorStackView.spacing = 8
        colorStackView.alignment = .leading
        colorStackView.distribution = .equalSpacing
        colorStackView.backgroundColor = .clear
        AlertColorSetModel.allCases.forEach {
            let button = self.createdButton($0.sendColor)
            self.colorStackView.addArrangedSubview(button)
        }
    }
    
    func bind() {
        let buttons = colorStackView.subviews.compactMap { $0 as? UIButton }

        Observable.merge(
            buttons.enumerated().map { index, button in
                button.rx.tap.map { index }
            }
        )
        .withUnretained(self)
        .subscribe(onNext: { owner, selectedIndex in
            owner.colorButtonTapped.accept(selectedIndex)
            debugPrint("\(selectedIndex)번째 버튼 선택됨")
        })
        .disposed(by: disposeBag)
        
        colorButtonTapped
            .asDriver(onErrorDriveWith: .empty())
            .drive { index in
                // 모든 버튼 초기화 후 선택된 버튼만 체크
                buttons.forEach {
                    $0.setImage(nil, for: .normal)
                    $0.alpha = 1
                }
                buttons[index].setImage(UIImage(systemName: "checkmark"), for: .normal)
                buttons[index].alpha = 0.6
            }
            .disposed(by: disposeBag)
    }

    
    func createdButton(_ color: UIColor?) -> UIButton {
        let button = UIButton()
        button.tintColor = .Personal.deepPink
        button.backgroundColor = color
        button.layer.cornerRadius = 16
        
        button.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }
        
        return button
    }
}

// MARK: - Reactive Extension

extension Reactive where Base: AlertColorSelectView {
    var colorButtonTapped: BehaviorRelay<Int> {
        base.colorButtonTapped
    }
}
