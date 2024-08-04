//
//  ShoppingListCell.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingListCell: UITableViewCell {
    static let id = "ShoppingListCell"
    var disposeBag = DisposeBag()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private let doneButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(likeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(doneButton)
        
        likeButton.snp.makeConstraints { make in
            make.top.leading.bottom.equalTo(contentView).inset(15)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.trailing.bottom.equalTo(contentView).inset(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.leading.equalTo(likeButton.snp.trailing).offset(15)
        }
        
        likeButton.setImage(UIImage(systemName: "star"), for: .normal)
        doneButton.setImage(UIImage(systemName: "square"), for: .normal)
        
        backgroundColor = .systemGray4
    }
}
