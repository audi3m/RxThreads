//
//  ShoppingList.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

struct ListItem {
    var title: String
    var like: Bool = false
    var done: Bool = false
}

final class ShoppingList: UIViewController {
    
    private let addItemBar: UISearchBar = {
        let bar = UISearchBar()
        bar.setImage(UIImage(systemName: "plus"), for: .search, state: .normal)
        bar.placeholder = "제목을 입력하세요"
        return bar
    }()
    private let tableView: UITableView = {
        let view = UITableView()
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private var items: [ListItem] = [
        ListItem(title: "asd"),
        ListItem(title: "hrte"),
        ListItem(title: "ahwerhgwersd"),
        ListItem(title: "asqwegd"),
        ListItem(title: "aswef3324d"),
        
    ]
    lazy var list = BehaviorSubject(value: items)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        
    }
    
    
}

extension ShoppingList {
    
    private func bind() {
        list
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingListCell.id, cellType: ShoppingListCell.self)) { row, element, cell in
                cell.titleLabel.text = element.title
            }
            .disposed(by: disposeBag)
        
        addItemBar.rx.searchButtonClicked
            .withLatestFrom(addItemBar.rx.text.orEmpty) { void, text in
                return text
            }
            .bind(with: self, onNext: { owner, value in
                guard !value.isEmpty else { return }
                let item = ListItem(title: value)
                owner.items.insert(item, at: 0)
                owner.list.onNext(owner.items)
                owner.addItemBar.text = ""
            })
            .disposed(by: disposeBag)
            
    }
}

extension ShoppingList {
    private func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "Shopping List"
        
        view.addSubview(addItemBar)
        view.addSubview(tableView)
        
        addItemBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(ShoppingListCell.self, forCellReuseIdentifier: "ShoppingListCell")
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addItemBar.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view)
        }
        
    }
}
