//
//  DiaryTableCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/20/25.
//

import UIKit
import SnapKit

final class DiaryTableCell: UITableViewCell {
    
    private lazy var dateView = createdLabel(.Personal.highlightPink)
    private lazy var titleView = createdLabel(.Gray.naturalBlack)
    
    private(set) var containerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reusedCell()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard containerView.bounds.contains(point) else { return nil }
        return super.hitTest(point, with: event)
    }
    
    func configureCell(_ date: Date, _ title: String) {
        dateView.text = date.formattedDateToString(.day)
        titleView.text = title
    }
}

// MARK: - UI Setting Method

private extension DiaryTableCell {
    
    func setupUI() {
        setupContainerView()
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        addSubview(containerView)
    }
    
    func setupLayout() {
        containerView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        dateView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60)
        }
        
        titleView.snp.makeConstraints {
            $0.leading.equalTo(dateView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setupContainerView() {
        containerView.backgroundColor = .white
        [dateView, titleView].forEach {
            containerView.addSubview($0)
        }
    }
    
    func createdLabel(_ color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = color
        label.numberOfLines = 1
        label.textAlignment = .left
        label.backgroundColor = .clear
        
        return label
    }
    
    func reusedCell() {
        dateView.text = ""
        titleView.text = ""
    }
}
