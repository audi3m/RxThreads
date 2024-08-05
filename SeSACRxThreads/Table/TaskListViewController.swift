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
        bar.placeholder = "제목을 입력하세요"
        bar.backgroundImage = UIImage()
        return bar
    }()
    private let tableView: UITableView = {
        let view = UITableView()
        view.keyboardDismissMode = .onDrag
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
}

extension TaskListViewController {
    
    private func bind() {
        
        let input = TaskViewModel.Input(addTap: addItemBar.rx.searchButtonClicked,
                                        searchText: searchBar.rx.text.orEmpty,
                                        newTaskTitle: addItemBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        // 즐겨찾기, 완료 버튼
        viewModel.tasks
            .bind(to: tableView.rx.items(cellIdentifier: TaskCell.id, cellType: TaskCell.self)) { row, task, cell in
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
        addItemBar.rx.searchButtonClicked
            .withLatestFrom(addItemBar.rx.text.orEmpty) { void, text in
                return text
            }
            .bind(with: self, onNext: { owner, value in
                guard !value.isEmpty else { return }
                let newItem = Task(title: value)
                owner.viewModel.originalTasks.insert(newItem, at: 0)
                owner.viewModel.tasks.accept(owner.viewModel.originalTasks)
                owner.addItemBar.text = ""
            })
            .disposed(by: disposeBag)
        
        // 삭제
        tableView.rx.itemDeleted
            .bind(with: self) { owner, indexPath in
                owner.viewModel.originalTasks.remove(at: indexPath.row)
                owner.viewModel.tasks.accept(owner.viewModel.originalTasks)
            }
            .disposed(by: disposeBag)
        
        // 상세화면 이동
        tableView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let vc = DetailView()
                vc.titleLabel.text = owner.viewModel.tasks.value[indexPath.row].title
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 검색
        searchBar.rx.text.orEmpty
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                print("실시간 검색어: \(value)")
                if !value.isEmpty {
                    let filteredTasks = owner.viewModel.originalTasks.filter { $0.title.contains(value) }
                    owner.viewModel.tasks.accept(filteredTasks)
                } else {
                    owner.viewModel.tasks.accept(owner.viewModel.originalTasks)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}

extension TaskListViewController {
    private func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "Task List"
        
        view.addSubview(searchBar)
        view.addSubview(addItemBar)
        view.addSubview(tableView)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addItemBar.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.id)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(addItemBar.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view)
        }
    }
}
