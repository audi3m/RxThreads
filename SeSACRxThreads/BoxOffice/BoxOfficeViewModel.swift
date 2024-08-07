//
//  BoxOfficeViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/7/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BoxOfficeViewModel {
    let disposeBag = DisposeBag()
    private let movieList = Observable.just(["Test 1", "Test 2", "Test 3"])
    private var recentList = ["Recent 1", "Recent 2", "Recent 3", "Recent 4"]
}

extension BoxOfficeViewModel {
    struct Input {
        // 테이블뷰 셀 클릭 문자열 -> 컬렉션뷰 업데이트
        let recentText: PublishSubject<String>
        let searchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
    }
    
    struct Output {
        let movieList: Observable<[String]>
        let recentList: BehaviorSubject<[String]>
    }
    
    func transform(input: Input) -> Output {
        let recentList = BehaviorSubject(value: recentList)
        
        input.recentText
            .subscribe(with: self) { owner, value in
                print("Transform", value)
                owner.recentList.append(value)
                recentList.onNext(owner.recentList)
            }
            .disposed(by: disposeBag)
        
        input.searchButtonTap
            .subscribe(with: self) { owner, _ in
                print("Search Tap")
            }
            .disposed(by: disposeBag)
        
        input.searchText
            .subscribe(with: self) { owner, value in
                print("Search: \(value)")
            }
            .disposed(by: disposeBag)
        
        return Output(movieList: movieList, recentList: recentList)
    }
}
