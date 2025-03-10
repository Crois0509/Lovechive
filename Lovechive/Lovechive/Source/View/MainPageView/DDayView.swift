//
//  DDayView.swift
//  Lovechive
//
//  Created by 장상경 on 3/9/25.
//

import UIKit
import SnapKit
import FirebaseFirestore

final class DDayView: UIView {
    
    private lazy var dDayView = createLabelView("", 20, .bold, .Personal.deepPink)
    private lazy var titleTextView = createLabelView("우리의 시작", 14, .regular, .Personal.highlightPink)
    private lazy var infoLabel = createLabelView("", 14, .regular, .Personal.highlightPink)
    
    private let textStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension DDayView {
    
    func setupUI() {
        setupUserState()
        setupStackView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .Personal.pointPink
        layer.cornerRadius = 16
        addSubview(textStackView)
    }
    
    func setupLayout() {
        textStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
    
    func setupStackView() {
        textStackView.axis = .vertical
        textStackView.spacing = 10
        textStackView.alignment = .fill
        textStackView.distribution = .fillEqually
        textStackView.backgroundColor = .clear
        [titleTextView, dDayView, infoLabel].forEach {
            textStackView.addArrangedSubview($0)
        }
    }
    
    func setupUserState() {
        FirestoreManager.shared.readFromFirestore(type: .couple) { [weak self] data in
            guard let self,
                  let userData = data?.first,
                  let startDay = (userData["dDay"] as? Timestamp)?.dateValue(),
                  let dDay = Calendar.current.dateComponents([.day], from: startDay, to: Date()).day
            else { return }
            
            self.infoLabel.text = "\(startDay.formattedDate())부터"
            self.dDayView.text = "D + \(dDay)"
        }
    }
    
    func createLabelView(_ title: String, _ size: CGFloat, _ weight: UIFont.Weight, _ color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = title
        label.textColor = color
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: size, weight: weight)
        
        return label
    }
    
}
