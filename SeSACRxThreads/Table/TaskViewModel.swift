//
//  TaskViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

struct Task {
    var title: String
    var like: Bool = false
    var done: Bool = false
}

final class TaskViewModel {
    
    let disposeBag = DisposeBag()
    
    var originalTasks: [Task] = []
    var tasks = BehaviorRelay<[Task]>(value: [])
    
    func transform(input: Input) -> Output {
        
        input.addTap
            .withLatestFrom(input.newTaskTitle) { void, text in
                return text
            }
            .bind(with: self) { owner, value in
                guard !value.isEmpty else { return }
                let newItem = Task(title: value)
                owner.originalTasks.insert(newItem, at: 0)
                owner.tasks.accept(owner.originalTasks)
            }
            .disposed(by: disposeBag)
        
        input.searchText
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                if !value.isEmpty {
                    let filteredTasks = owner.originalTasks.filter { $0.title.contains(value) }
                    owner.tasks.accept(filteredTasks)
                } else {
                    owner.tasks.accept(owner.originalTasks)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output()
    }
    
}

extension TaskViewModel {
    struct Input {
        let addTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
        let newTaskTitle: ControlProperty<String>
        
        
        
    }
    
    struct Output {
        
    }
}

extension TaskViewModel {
    func toggleDone(at index: Int) {
        originalTasks[index].done.toggle()
        tasks.accept(originalTasks)
    }
    
    func toggleLike(at index: Int) {
        originalTasks[index].like.toggle()
        tasks.accept(originalTasks)
    }
}

//private func bind() {
//    tasks
//        .bind(to: tableView.rx.items(cellIdentifier: TaskCell.id, cellType: TaskCell.self)) { row, task, cell in
//            cell.task = task
//            cell.likeButton.rx.tap
//                .bind(with: self) { owner, _ in
//                    owner.toggleLike(at: row)
//                }
//                .disposed(by: cell.disposeBag)
//            cell.doneButton.rx.tap
//                .bind(with: self) { owner, _ in
//                    owner.toggleDone(at: row)
//                }
//                .disposed(by: cell.disposeBag)
//        }
//        .disposed(by: disposeBag)
//    
//    addItemBar.rx.searchButtonClicked
//        .withLatestFrom(addItemBar.rx.text.orEmpty) { void, text in
//            return text
//        }
//        .bind(with: self, onNext: { owner, value in
//            guard !value.isEmpty else { return }
//            let newItem = Task(title: value)
//            owner.originalTasks.insert(newItem, at: 0)
//            owner.tasks.accept(owner.originalTasks)
//            owner.addItemBar.text = ""
//        })
//        .disposed(by: disposeBag)
//    
//    tableView.rx.itemDeleted
//        .bind(with: self) { owner, indexPath in
//            owner.originalTasks.remove(at: indexPath.row)
//            owner.tasks.accept(owner.originalTasks)
//        }
//        .disposed(by: disposeBag)
//    
//    tableView.rx.itemSelected
//        .bind(with: self, onNext: { owner, indexPath in
//            let vc = DetailView()
//            vc.titleLabel.text = owner.tasks.value[indexPath.row].title
//            owner.navigationController?.pushViewController(vc, animated: true)
//        })
//        .disposed(by: disposeBag)
//    
//    searchBar.rx.text.orEmpty
////            .debounce(.seconds(1), scheduler: MainScheduler.instance)
//        .distinctUntilChanged()
//        .bind(with: self) { owner, value in
//            print("실시간 검색어: \(value)")
//            if !value.isEmpty {
//                let filteredTasks = owner.originalTasks.filter { $0.title.contains(value) }
//                owner.tasks.accept(filteredTasks)
//            } else {
//                owner.tasks.accept(owner.originalTasks)
//            }
//        }
//        .disposed(by: disposeBag)
//    
//}
//
//private func toggleDone(at index: Int) {
//    originalTasks[index].done.toggle()
//    tasks.accept(originalTasks)
//}
//
//private func toggleLike(at index: Int) {
//    originalTasks[index].like.toggle()
//    tasks.accept(originalTasks)
//}
