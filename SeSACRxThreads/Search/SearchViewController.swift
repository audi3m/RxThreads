//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
        return view
    }()
    
    let searchBar = UISearchBar()
    
    let disposeBag = DisposeBag()
    
    var data = ["A", "B", "C", "AB", "D",
                "ABC", "BBB", "EC", "SA",
                "AAAB", "ED", "F", "G", "H"]
    
    lazy var list = BehaviorSubject(value: data)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configure()
        setSearchController()
        bind()
    }
    
    func bind() {
        list
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = element
                cell.appIconImageView.backgroundColor = .systemBlue
                cell.downloadButton.rx.tap
                    .bind(with: self) { owner, _ in
                        print("\(row) Clicked")
                        owner.navigationController?.pushViewController(DetailViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 기능 추가하고 싶을 때
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text.orEmpty) { void, text in
                return text
            }
            .bind(with: self, onNext: { owner, value in
                owner.data.insert(value, at: 0)
                owner.list.onNext(owner.data)
            })
//            .bind(with: self) { owner, _ in
//                let word = owner.searchBar.text!
//                owner.data.insert(word, at: 0)
//                owner.list.onNext(owner.data)
//            }
            .disposed(by: disposeBag)
        
        // debounce vs throttle
        searchBar.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged() // 같은 검색어 방지
            .bind(with: self) { owner, value in
                print("실시간 검색어: \(value)")
                if !value.isEmpty {
                    let result = owner.data.filter { $0.contains(value) }
                    owner.list.onNext(result)
                } else {
                    owner.list.onNext(owner.data)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        print("추가 버튼 클릭")
    }
    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
