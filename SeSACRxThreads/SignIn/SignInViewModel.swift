//
//  SignInViewModel.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import Foundation
import RxSwift
import RxCocoa

protocol BaseViewModel {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    
}

final class SignInViewModel: BaseViewModel {
    
    struct Input {
        let tap: ControlEvent<Void>
    }
    
    struct Output {
        let text: Driver<Joke> // 공유 스트림, 메인 쓰레드
//        let text: Observable<Joke>
    }
    
    func transform(input: Input) -> Output {
        let result = input.tap // dispose 되지 않고 계속 유지
            .flatMap {
                NetworkManager.shared.fetchJokeWithSingle()
                    .catch { error in  // error일 때만
                        return Single<Joke>.never()
                    }
            }
//            .catch { error in  // error일 때만
//                return Observable.just(Joke(joke: "Fail", id: 0))
//            }
//            .asSingle() // 1) 뷰에 결과가 안나옴, 2) 탭 이벤트 전달x, 3) 실패 - 탭 안됨. 통신만 oxox 되어야 하는데 탭 자체가 dispose됨
            .asDriver(onErrorJustReturn: Joke(joke: "FAIL", id: 0))
            .debug("Button Tap")
        
        return Output(text: result)
    }
    
}
