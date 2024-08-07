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

final class TaskTableViewCell: UITableViewCell {
    static var id: String {
        String(describing: self)
    }
    var disposeBag = DisposeBag()
    var task: Task?
    
    let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    let doneButton: UIButton = {
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
        configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
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
        
    }
    
    func configureData() {
        guard let task else { return }
        titleLabel.text = task.title
        likeButton.setImage(UIImage(systemName: task.like ? "star.fill" : "star"), for: .normal)
        doneButton.setImage(UIImage(systemName: task.done ? "checkmark.square" : "square"), for: .normal)
    }
}
