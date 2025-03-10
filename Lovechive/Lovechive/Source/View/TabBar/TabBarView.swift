//
//  TabBarView.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 탭바 UI를 구현하는 뷰
final class TabBarView: UIView {
    
    // MARK: - UI Components
    
    fileprivate lazy var firstTabButton: UIButton = createTabButton(state: .home)
    fileprivate lazy var secondTabButton: UIButton = createTabButton(state: .calendar)
    fileprivate lazy var thirdTabButton: UIButton = createTabButton(state: .diary)
    fileprivate lazy var forthTabButton: UIButton = createTabButton(state: .setting)
    
    private lazy var buttonStack = UIStackView() // 탭바 버튼들을 담을 스택
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 버튼의 상태를 변경하는 메소드
    /// - Parameter state: 변경할 버튼의 상태
    func changeButtonState(state: TabBarButtonState) {
        switch state {
        case .home:
            firstTabButton.configuration?.baseForegroundColor = UIColor.Personal.highlightPink
            secondTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            thirdTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            forthTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
        case .calendar:
            firstTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            secondTabButton.configuration?.baseForegroundColor = UIColor.Personal.highlightPink
            thirdTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            forthTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
        case .diary:
            firstTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            secondTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            thirdTabButton.configuration?.baseForegroundColor = UIColor.Personal.highlightPink
            forthTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
        case .setting:
            firstTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            secondTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            thirdTabButton.configuration?.baseForegroundColor = UIColor.Gray.unSelected
            forthTabButton.configuration?.baseForegroundColor = UIColor.Personal.highlightPink
        }
    }
    
}

// MARK: - UI Setting Method

private extension TabBarView {
    
    func setupUI() {
        setupStackView()
        configureSelf()
        setupLayout()
        changeButtonState(state: .home) // 기본 값: 홈
    }
    
    func configureSelf() {
        self.backgroundColor = .clear
        self.addSubview(buttonStack)
    }
    
    func setupLayout() {
        buttonStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupStackView() {
        buttonStack.axis = .horizontal
        buttonStack.spacing = 0
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.backgroundColor = .white
        buttonStack.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        buttonStack.layer.shadowOpacity = 0.25
        buttonStack.layer.shadowRadius = 2
        buttonStack.layer.shadowOffset = .init(width: 0, height: -4)
        [firstTabButton, secondTabButton, thirdTabButton, forthTabButton].forEach {
            buttonStack.addArrangedSubview($0)
        }
    }
    
    /// 탭바의 버튼을 생성하는 메소드
    /// - Parameter state: 생성할 버튼의 상태
    /// - Returns: 탭바 버튼 UI
    func createTabButton(state: TabBarButtonState) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = state.tabTitle
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .regular)  // 원하는 폰트 설정
            return outgoing
        }
        
        config.image = state.tabImage.withRenderingMode(.alwaysTemplate)
        config.baseBackgroundColor = .clear
        config.imagePadding = 2
        config.imagePlacement = .top
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let button = UIButton()
        button.configuration = config
        
        return button
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: TabBarView {
    var firstButtonTapped: ControlEvent<Void> {
        base.firstTabButton.rx.tap
    }
    
    var secondButtonTapped: ControlEvent<Void> {
        base.secondTabButton.rx.tap
    }
    
    var thirdButtonTapped: ControlEvent<Void> {
        base.thirdTabButton.rx.tap
    }
    
    var forthButtonTapped: ControlEvent<Void> {
        base.forthTabButton.rx.tap
    }
}
