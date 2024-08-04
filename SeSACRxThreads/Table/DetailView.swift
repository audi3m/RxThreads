//
//  DetailView.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/4/24.
//

import UIKit
import SnapKit

final class DetailView: UIViewController {
    let titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    var item: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "상세 화면"
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}
