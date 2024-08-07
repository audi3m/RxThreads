//
//  SearchViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/7/24.
//

import Foundation
import RxSwift

final class SearchViewModel {
    
    let disposeBag = DisposeBag()
    
    let inputQuery = PublishSubject<String>()
    let inputSearchButtonTap = PublishSubject<Void>()
    
    private var data = ["A", "B", "C", "AB", "D", "ABC", "BBB",
                        "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    
    lazy var list = BehaviorSubject(value: data)
    
    init() {
        
        inputQuery
            .subscribe(with: self) { owner, value in
                print("Input query chaged: \(value)")
            }
            .disposed(by: disposeBag)
        
        inputQuery
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged() // 같은 검색어 방지
            .subscribe(with: self) { owner, value in
                print("실시간 검색어: \(value)")
                if !value.isEmpty {
                    let result = owner.data.filter { $0.contains(value) }
                    owner.list.onNext(result)
                } else {
                    owner.list.onNext(owner.data)
                }
            }
            .disposed(by: disposeBag)
        
//        inputSearchButtonTap
//            .withLatestFrom(inputQuery)
//            .subscribe(with: self) { owner, value in
//                print("Input clicked: \(value)")
//                owner.data.insert(value, at: 0)
//                owner.list.onNext(owner.data)
//            }
//            .disposed(by: disposeBag)
    }
    
}
