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

protocol TaskViewModelDelegate: AnyObject {
    func pushDetail(title: String)
}

final class TaskViewModel {
    
    weak var delegate: TaskViewModelDelegate?
    
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
        
        input.deleteAt
            .bind(with: self) { owner, indexPath in
                owner.originalTasks.remove(at: indexPath.row)
                owner.tasks.accept(owner.originalTasks)
            }
            .disposed(by: disposeBag)
        
        input.pushDetail
            .bind(with: self, onNext: { owner, indexPath in
                let title = owner.tasks.value[indexPath.row].title
                owner.delegate?.pushDetail(title: title)
            })
            .disposed(by: disposeBag)
        
        return Output(addTap: input.addTap)
    }
}

extension TaskViewModel {
    struct Input {
        let addTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
        let newTaskTitle: ControlProperty<String>
        let deleteAt: ControlEvent<IndexPath>
        let pushDetail: ControlEvent<IndexPath>
    }
    
    struct Output {
        let addTap: ControlEvent<Void>
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
