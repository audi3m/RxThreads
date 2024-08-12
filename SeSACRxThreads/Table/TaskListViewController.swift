//
//  TaskListViewController.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/4/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TaskListViewController: UIViewController {
    
    let viewModel = TaskViewModel()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "검색어를 입력하세요"
        bar.backgroundImage = UIImage()
        return bar
    }()
    private let addItemBar: UISearchBar = {
        let bar = UISearchBar()
        bar.setImage(UIImage(systemName: "plus"), for: .search, state: .normal)
        bar.placeholder = "새로운 일의 제목을 입력하세요"
        bar.backgroundImage = UIImage()
        return bar
    }()
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout())
        view.register(TaskCollectionViewCell.self, forCellWithReuseIdentifier: TaskCollectionViewCell.id)
        view.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private let tableView: UITableView = {
        let view = UITableView()
        view.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.id)
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private var mode: SearchBarMode = .search
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        configureView()
        bind()
    }
}

extension TaskListViewController: TaskViewModelDelegate {
    
    private func bind() {
        let recentText = PublishSubject<String>()
        
        let input = TaskViewModel.Input(recentText: recentText,
                                        addTap: addItemBar.rx.searchButtonClicked,
                                        searchText: searchBar.rx.text.orEmpty,
                                        newTaskTitle: addItemBar.rx.text.orEmpty, 
                                        deleteAt: tableView.rx.itemDeleted,
                                        pushDetail: tableView.rx.itemSelected)
        
        let output = viewModel.transform(input: input)
        
        viewModel.dummyTasks
            .bind(to: collectionView.rx.items(cellIdentifier: TaskCollectionViewCell.id, cellType: TaskCollectionViewCell.self)) { (row, element, cell) in
                cell.label.text = element
            }
            .disposed(by: disposeBag)
        
        // 즐겨찾기, 완료 버튼
        viewModel.tasks
            .bind(to: tableView.rx.items(cellIdentifier: TaskTableViewCell.id, cellType: TaskTableViewCell.self)) { row, task, cell in
                cell.task = task
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.viewModel.toggleLike(at: row)
                    }
                    .disposed(by: cell.disposeBag)
                cell.doneButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.viewModel.toggleDone(at: row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        // 추가
        output.addTap
            .bind(with: self, onNext: { owner, _ in
                owner.addItemBar.text = ""
            })
            .disposed(by: disposeBag)
        
        Observable.zip(collectionView.rx.modelSelected(String.self), collectionView.rx.itemSelected)
            .map { $0.0 }
            .subscribe(with: self) { owner, value in
                recentText.onNext(value)
            }
            .disposed(by: disposeBag)
    }
    
    func pushDetail(title: String) {
        let vc = DetailView()
        vc.titleLabel.text = title
        navigationController?.pushViewController(vc, animated: true)
    }
}

// View
extension TaskListViewController {
    private func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "Task List"
        
        let switcher = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                   style: .plain, target: self,
                                   action: #selector(switchMode))
        
        navigationItem.rightBarButtonItem = switcher
        
        view.addSubview(searchBar)
        view.addSubview(addItemBar)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addItemBar.isHidden = true
        addItemBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view)
        }
    }
    
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 35)
        
        layout.scrollDirection = .horizontal
        return layout
    }
    
    @objc private func switchMode() {
        if mode == .search {
            searchBar.isHidden = true
            searchBar.text = ""
            addItemBar.isHidden = false
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "magnifyingglass")
            mode = .addNew
        } else {
            searchBar.isHidden = false
            addItemBar.isHidden = true
            addItemBar.text = ""
            navigationItem.rightBarButtonItem?.image = UIImage(systemName: "plus")
            mode = .search
        }
    }
    
    enum SearchBarMode {
        case search
        case addNew
    }
}
