//
//  BoxOfficeViewController.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BoxOfficeViewController: UIViewController {
    
    let viewModel = BoxOfficeViewModel()
    let disposeBag = DisposeBag()
    
    let searchBar = UISearchBar()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
}

// Rx
extension BoxOfficeViewController {
    private func bind() {
        
        let recentText = PublishSubject<String>()
        
        let input = BoxOfficeViewModel.Input(recentText: recentText,
                                             searchButtonTap: searchBar.rx.searchButtonClicked,
                                             searchText: searchBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        // collectionView
        output.recentList
            .bind(to: collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.id, cellType: MovieCollectionViewCell.self)) { (row, element, cell) in
                cell.label.text = element
            }
            .disposed(by: disposeBag)
        
        // tableView
        output.movieList
            .bind(to: tableView.rx.items(cellIdentifier: MovieTableViewCell.id, cellType: MovieTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = element
            }
            .disposed(by: disposeBag)
        
        // 셀 클릭 - 합치기
        Observable.zip(tableView.rx.modelSelected(String.self), tableView.rx.itemSelected)
            .map { "검색어는 \($0.0)" }
            .subscribe(with: self) { owner, value in
                recentText.onNext(value)
            }
            .disposed(by: disposeBag)
    }
}

// View
extension BoxOfficeViewController {
    private func configureView() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        navigationItem.titleView = searchBar
        
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.id)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.id)
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view)
        }
    }
    
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
    
}
