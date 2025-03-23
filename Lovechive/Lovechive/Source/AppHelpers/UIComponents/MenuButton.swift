//
//  MenuButton.swift
//  Lovechive
//
//  Created by 장상경 on 3/23/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MenuButton: UIView {
    
    private let titleView = UILabel()
    private let menuButton = UIButton()
    
    fileprivate let menuRelay = BehaviorRelay<String>(value: "")
    
    private var menuList: [String]
    
    init(title: String, menus: [String]) {
        self.menuList = menus
        super.init(frame: .zero)
        
        self.titleView.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI Setting Method

private extension MenuButton {
    
    func setupUI() {
        setupTitleView()
        setupMenuView()
        configureMenuForButton()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [menuButton, titleView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        menuButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        titleView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.equalTo(menuButton.snp.leading)
        }
    }
    
    func configureMenuForButton() {
        
        let childrens: [UIAction] = {
            var childrens: [UIAction] = []
            
            menuList.forEach { menu in
                let action = UIAction(title: menu) { [weak self] _ in
                    guard let self else { return }
                    self.menuButton.setTitle(menu, for: .normal)
                    self.menuRelay.accept(menu)
                    UserDefaults.standard.set(menu, forKey: self.titleView.text!)
                }
                childrens.append(action)
            }
            return childrens
        }()
        
        let menu = UIMenu(title: titleView.text ?? "", options: .displayInline, children: childrens)
        
        menuButton.menu = menu
        menuButton.showsMenuAsPrimaryAction = true
    }
    
    func setupTitleView() {
        titleView.textColor = .Gray.naturalBlack
        titleView.font = .systemFont(ofSize: 14, weight: .regular)
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupMenuView() {
        let menu = UserDefaults.standard.object(forKey: titleView.text!) as? String == nil ? "" : UserDefaults.standard.string(forKey: titleView.text!)!
        
        menuButton.setTitle(menu, for: .normal)
        menuButton.setTitleColor(.Personal.highlightPink, for: .normal)
        menuButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        menuButton.titleLabel?.numberOfLines = 1
        menuButton.titleLabel?.textAlignment = .right
        menuButton.backgroundColor = .clear
    }
    
}

// MARK: - Reactive Extension

extension Reactive where Base: MenuButton {
    var changedMenu: BehaviorRelay<String> {
        base.menuRelay
    }
}
