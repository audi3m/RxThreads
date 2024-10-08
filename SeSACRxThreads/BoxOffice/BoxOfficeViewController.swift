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
    let singleViewModel = BoxSingleViewModel()
    let disposeBag = DisposeBag()
    
    let searchBar = UISearchBar()
//    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        newBind()
    }
}

// Rx
extension BoxOfficeViewController {
    
    // Observable Create Practice
    // create
    private func createObservable() {
        let random = Observable<Int>.create { value in
            let result = Int.random(in: 1...100)
            if result >= 1 && result <= 45 {
                value.onNext(result)
            } else {
                value.onCompleted()
            }
            return Disposables.create()
        }
        
        // Observable
        random
            .subscribe(with: self) { owner, value in
                print("random: \(value)")
            } onCompleted: { _ in
                print("Completed")
            } onDisposed: { _ in
                print("Disposed")
            }
            .disposed(by: disposeBag)
    }
    
    private func newBind() {
        let input = BoxSingleViewModel.Input(tap: searchBar.rx.searchButtonClicked,
                                             searchDate: searchBar.rx.text.orEmpty)
        let output = singleViewModel.transform(input: input)
        
        output.movieList
            .drive(tableView.rx.items(cellIdentifier: MovieTableViewCell.id, cellType: MovieTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = element.movieNm
                cell.downloadButton.setTitle(element.openDt, for: .normal)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func bind() {
        
        let input = BoxOfficeViewModel.Input(searchButtonTap: searchBar.rx.searchButtonClicked,
                                             searchText: searchBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        // collectionView
//        output.recentList
//            .bind(to: collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.id, cellType: MovieCollectionViewCell.self)) { (row, element, cell) in
//                cell.label.text = element
//            }
//            .disposed(by: disposeBag)
        
        // tableView
        output.movieList
            .bind(to: tableView.rx.items(cellIdentifier: MovieTableViewCell.id, cellType: MovieTableViewCell.self)) { (row, element, cell) in
                cell.appNameLabel.text = element.movieNm
                cell.downloadButton.setTitle(element.openDt, for: .normal)
            }
            .disposed(by: disposeBag)
    }
}

// View
extension BoxOfficeViewController {
    private func configureView() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
//        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        navigationItem.titleView = searchBar
        
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.id)
//        collectionView.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide)
//            make.horizontalEdges.equalToSuperview()
//            make.height.equalTo(50)
//        }
        
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.id)
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
//    static func layout() -> UICollectionViewFlowLayout {
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 120, height: 40)
//        layout.scrollDirection = .horizontal
//        return layout
//    }
    
}
