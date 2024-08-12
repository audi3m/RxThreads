//
//  BoxOfficeViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/7/24.
//

/*
 Observable Create
 Network.. AF.request.. >>
 - Memory Leak
 - RxSwift Single
 */

import Foundation
import RxSwift
import RxCocoa

final class BoxOfficeViewModel: BaseViewModel {
    let disposeBag = DisposeBag()
}

extension BoxOfficeViewModel {
    struct Input {
        // 테이블뷰 셀 클릭 문자열 -> 컬렉션뷰 업데이트
        let searchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
    }
    
    struct Output {
        let movieList: Observable<[DailyBoxOfficeList]>
    }
    
    func transform(input: Input) -> Output {
        let boxOfficeList = PublishSubject<[DailyBoxOfficeList]>()
        
        // Observable 안에 Observable이 있는 형태
        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText) // 20240801
            .distinctUntilChanged()
            .map {
                guard let intText = Int($0) else {
                    return 20240801
                }
                return intText
            }
            .map { return "\($0)" }
            .flatMap { value in // (map) vs (flatMap)
                NetworkManager.shared.callBoxOffice(date: value)
            }
            .subscribe(with: self, onNext: { owner, movie in
                boxOfficeList.onNext(movie.boxOfficeResult.dailyBoxOfficeList)
            }, onError: { owner, error in
                print(error)
            }, onCompleted: { _ in
                print("completed")
            }, onDisposed: { _ in
                print("disposed")
            })
            .disposed(by: disposeBag)
        
        input.searchText
            .subscribe(with: self) { owner, value in
                print("Search: \(value)")
            }
            .disposed(by: disposeBag)
        
        return Output(movieList: boxOfficeList)
    }
}
