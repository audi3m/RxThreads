//
//  BirthdayViewModel.swift
//  SeSACRxThreads
//
//  Created by J Oh on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    
    let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let year = BehaviorRelay(value: 2024)
        let month = BehaviorRelay(value: 8)
        let day = BehaviorRelay(value: 5)
        
        input.birthday // 여기까지 input
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
                year.accept(component.year!)
                month.accept(component.month!)
                day.accept(component.day!)
            }
            .disposed(by: disposeBag)
        
        return Output(year: year, month: month, day: day, nextTap: input.nextTap)
        
    }
}

extension BirthdayViewModel {
    struct Input {
        let birthday: ControlProperty<Date>
        let nextTap: ControlEvent<Void>
    }
    
    struct Output {
        let year: BehaviorRelay<Int>
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let nextTap: ControlEvent<Void>
    }
}


//owner.year.accept(component.year!)
//owner.month.accept(component.month!)
//owner.day.accept(component.day!)
//owner.yearLabel.text = "\(component.year!)년"
//owner.monthLabel.text = "\(component.month!)월"
//owner.dayLabel.text = "\(component.day!)일"
