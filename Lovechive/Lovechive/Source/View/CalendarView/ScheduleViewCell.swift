//
//  ScheduleViewCell.swift
//  Lovechive
//
//  Created by 장상경 on 3/11/25.
//

import UIKit
import SnapKit

final class ScheduleViewCell: UITableViewCell {
    
    private lazy var timeLabel = createdLabel(title: AppConfig.CalendarViewConfig.cellDate, color: .Gray.unSelected, size: 14)
    private lazy var titleLabel = createdLabel(title: AppConfig.CalendarViewConfig.cellTitle, color: .Gray.naturalBlack, size: 16)
    
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
    
    func configureCell(time: Date, title: String) {
        timeLabel.text = time.formattedDateToScheduleTime()
        titleLabel.text = title
    }
    
}

private extension ScheduleViewCell {
    
    func setupUI() {
        configureSelf()
        setupLayout()
    }
    
    func configureSelf() {
        backgroundColor = .clear
        [timeLabel, titleLabel].forEach {
            addSubview($0)
        }
    }
    
    func setupLayout() {
        timeLabel.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
            $0.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(timeLabel.snp.trailing)
            $0.verticalEdges.trailing.equalToSuperview()
        }
    }
    
    func reusedCell() {
        timeLabel.text = ""
        titleLabel.text = ""
    }
    
    func createdLabel(title: String, color: UIColor, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: size, weight: .regular)
        label.textColor = color
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }
    
}
