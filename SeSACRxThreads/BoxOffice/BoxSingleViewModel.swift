//
//  BoxSingleViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/12/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BoxSingleViewModel: BaseViewModel {
    
    let disposeBag = DisposeBag() 
    private var recentList = ["Recent 1", "Recent 2", "Recent 3", "Recent 4"]
    
    struct Input {
        let tap: ControlEvent<Void>
        let searchDate: ControlProperty<String>
    }
    
    struct Output {
        let movieList: Driver<Movie>
    }
    
    func transform(input: Input) -> Output {
        let result = input.tap
            .withLatestFrom(input.searchDate.asObservable())
            .flatMap { date in
                NetworkManager.shared.requestBoxOffice(date: date)
                    .catch { error in  // error일 때만
                        return Single<Movie>.never()
                    }
            }
            .asDriver(onErrorJustReturn: Movie(boxOfficeResult: BoxOfficeResult(dailyBoxOfficeList: [])))
            .debug("Button Tap")
        
        return Output(movieList: result)
    }
    
}
