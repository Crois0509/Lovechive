//
//  LovechiveAlertView.swift
//  Lovechive
//
//  Created by 장상경 on 3/12/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LovechiveAlertView: UIView {
        
    private let titleView = UILabel()
    fileprivate let buttonView: AlertButtonStackView
    private lazy var sectionView = UICollectionView(frame: .zero, collectionViewLayout: createdCollectionViewLayout(items: 1))
    
    private var disposeBag = DisposeBag()
    
    fileprivate let firstSectionTextFieldRelay = BehaviorRelay<String>(value: "")
    fileprivate let secondSectionTextFieldRelay = BehaviorRelay<String>(value: "")
    fileprivate let thirdSectionTextFieldRelay = BehaviorRelay<String>(value: "")
    fileprivate let thirdSectionColorRelay = BehaviorRelay<String>(value: "")
    
    private lazy var sections: [[UIView]] = [
        [AlertTextFieldView(type: .time, placeHolder: "시간 선택"), AlertTextFieldView(type: .limit(value: 20), placeHolder: "일정 설명")],
        [AlertTextFieldView(type: .limit(value: 10), placeHolder: "다이어리 제목"), AlertTextFieldView(type: .limit(value: 20), placeHolder: "다이어리 설명")],
        []
    ]
    
    private var currentSectionIndex: Int
    private var currentType: FirestoreModelProtocol?
    
    init(type: AlertTypes) {
        buttonView = .init(aletType: type)
        currentSectionIndex = type.typeIndex
        super.init(frame: .zero)
        
        titleView.text = type.alertTitle
        sectionView.setCollectionViewLayout(createdCollectionViewLayout(items: sections[currentSectionIndex].count), animated: false)
        editData(type: type)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSectionViewSize() {
        let constraint: Int = currentSectionIndex == 2 ? 64 : 48
        sectionView.layoutIfNeeded()
        sectionView.snp.updateConstraints {
            $0.height.equalTo(constraint * self.sections[self.currentSectionIndex].count)
        }
    }
}

private extension LovechiveAlertView {
    
    func setupUI() {
        setupSectinoView()
        setupTitle()
        configureSelf()
        setupLayout()
        bind()
    }
    
    func configureSelf() {
        backgroundColor = .white
        layer.cornerRadius = 16
        [titleView, sectionView, buttonView].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        titleView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(30)
        }
        
        sectionView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(96) // 기본 높이
        }
        
        buttonView.snp.makeConstraints {
            $0.top.equalTo(sectionView.snp.bottom).offset(16)
            $0.bottom.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
    }
    
    func setupTitle() {
        titleView.font = .systemFont(ofSize: 16, weight: .bold)
        titleView.textColor = .Gray.naturalBlack
        titleView.numberOfLines = 1
        titleView.textAlignment = .left
        titleView.backgroundColor = .clear
    }
    
    func setupSectinoView() {
        sectionView.backgroundColor = .clear
        sectionView.isScrollEnabled = false
        sectionView.showsHorizontalScrollIndicator = false
        sectionView.showsVerticalScrollIndicator = false
        sectionView.dataSource = self
        sectionView.register(AlertSectionCell.self, forCellWithReuseIdentifier: "AlertSectionCell")
    }
    
    func createdCollectionViewLayout(items: Int) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1 / CGFloat(items)))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func editData(type: AlertTypes) {
        switch type {
        case .newSchedule, .newDiary: break
        case .editSchedule(data: let data):
            let section = sections[0]
            guard let firstView = section[0] as? AlertTextFieldView,
                  let secondView = section[1] as? AlertTextFieldView
            else { return }
            
            firstView.configureTextField(data.date.formattedDateToString(.hourMinute))
            secondView.configureTextField(data.title)
            
        case .editDiary: break
        case .editMyPage: break
        }
    }
        
    func bind() {
        sections[currentSectionIndex].enumerated().forEach { [weak self] (index, section) in
            guard let self else { return }
            if let view = section as? AlertTextFieldView, index == 0 {
                view.rx.editingTextField.bind(to: self.firstSectionTextFieldRelay).disposed(by: disposeBag)
            } else if let view = section as? AlertTextFieldView, index == 1 {
                view.rx.editingTextField.bind(to: self.secondSectionTextFieldRelay).disposed(by: disposeBag)
            } else if let view = section as? AlertTextFieldView, index == 1 {
                // 추후 구현
            }
        }
    }
    
}

extension LovechiveAlertView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[currentSectionIndex].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlertSectionCell", for: indexPath) as? AlertSectionCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(sections[currentSectionIndex][indexPath.item])
        cell.backgroundColor = .clear
        
        return cell
    }
}

extension Reactive where Base: LovechiveAlertView {
    var layoutSubviewsEvent: Observable<Void> {
        return base.rx.methodInvoked(#selector(base.layoutSubviews))
            .map { _ in } // 반환값을 Void로 변환
    }
    
    var cancelButtonTapped: ControlEvent<Void> {
        return base.buttonView.rx.cancelButtonTapped
    }
    
    var activeButtonTapped: ControlEvent<Void> {
        return base.buttonView.rx.activeButtonTapped
    }
    
    var firstSectionTextFieldRelay: BehaviorRelay<String> {
        return base.firstSectionTextFieldRelay
    }
    
    var secondSectionTextFieldRelay: BehaviorRelay<String> {
        return base.secondSectionTextFieldRelay
    }
    
    var thirdSectionTextFieldRelay: BehaviorRelay<String> {
        return base.thirdSectionTextFieldRelay
    }
    
    var thirdSectionColorRelay: BehaviorRelay<String> {
        return base.thirdSectionColorRelay
    }
}
