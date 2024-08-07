//
//  TaskCollectionViewCell.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/7/24.
//

import UIKit
import SnapKit

final class TaskCollectionViewCell: UICollectionViewCell {
    
    static let id = "TaskCollectionViewCell"
    
    let label = BasePaddingLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

