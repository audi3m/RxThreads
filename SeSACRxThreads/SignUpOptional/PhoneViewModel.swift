//
//  PhoneViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneViewModel {
    
    func transform(input: Input) -> Output {
        let validation = input.text
            .map { $0.count >= 8 }
        let validText = Observable.just("연락처는 8자 이상")
        return Output(tap: input.tap, validText: validText, validation: validation)
    }
}

extension PhoneViewModel {
    struct Input {
        let tap: ControlEvent<Void> // nextButton.rx.tap
        let text: ControlProperty<String> // phoneTextField.rx.text
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let validText: Observable<String>
        let validation: Observable<Bool>
    }
}
