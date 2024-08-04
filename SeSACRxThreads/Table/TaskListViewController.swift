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

struct Task {
    var title: String
    var like: Bool = false
    var done: Bool = false
}

final class TaskListViewController: UIViewController {
    
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
    private var tasks = BehaviorRelay<[Task]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
}

extension TaskListViewController: UITableViewDelegate {
    
    private func bind() {
        tasks
            .bind(to: tableView.rx.items(cellIdentifier: TaskCell.id, cellType: TaskCell.self)) { row, task, cell in
                cell.task = task
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.toggleLike(at: row)
                    }
                    .disposed(by: cell.disposeBag)
                cell.doneButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.toggleDone(at: row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        addItemBar.rx.searchButtonClicked
            .withLatestFrom(addItemBar.rx.text.orEmpty) { void, text in
                return text
            }
            .bind(with: self, onNext: { owner, value in
                guard !value.isEmpty else { return }
                let newItem = Task(title: value)
                var tasks = owner.tasks.value
                tasks.insert(newItem, at: 0)
                owner.tasks.accept(tasks)
                owner.addItemBar.text = ""
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .bind(with: self) { owner, indexPath in
                var tasks = owner.tasks.value
                tasks.remove(at: indexPath.row)
                owner.tasks.accept(tasks)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let vc = DetailView()
                vc.titleLabel.text = owner.tasks.value[indexPath.row].title
                owner.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
    }
    
    private func toggleDone(at index: Int) {
        var task = tasks.value
        task[index].done.toggle()
        tasks.accept(task)
    }
    
    private func toggleLike(at index: Int) {
        var task = tasks.value
        task[index].like.toggle()
        tasks.accept(task)
    }
}

extension TaskListViewController {
    private func configureView() {
        view.backgroundColor = .white
        navigationItem.title = "Task List"
        
        view.addSubview(addItemBar)
        view.addSubview(tableView)
        
        addItemBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
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
