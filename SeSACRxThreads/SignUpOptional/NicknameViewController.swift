//
//  NicknameViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NicknameViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        newBind()
    }
    
    private func newBind() {
        
        // share 없이 공유할 수 없을까?
        // subscribe에서 ui스럽게 bind로 왔는데
        // 스트림 공유해주는 방법: drive (subscribe, bind, drive)
        let tapEvent = nextButton.rx.tap
            .map { "안녕하세요: \(Int.random(in: 1...100))" }
            .asDriver(onErrorJustReturn: "")
        
        tapEvent
            .drive(nextButton.rx.title())
            .disposed(by: disposeBag)
        
        tapEvent
            .drive(nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        tapEvent
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
    }
    
    private func bind() {
        
        // Observable Stream 이 공유되지 않음.
        // 구독할 때마다 새로운 스트림이 생기기 때문.
        let tapEvent = nextButton.rx.tap
            .map { "안녕하세요: \(Int.random(in: 1...100))" }
            .share() // 불필요한 스트림 발생 방지
        
        tapEvent
            .bind(to: nextButton.rx.title())
            .disposed(by: disposeBag)
        
        tapEvent
            .bind(to: nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        tapEvent
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
//        tapEvent
//            .bind(to: nextButton.rx.title(), nicknameTextField.rx.text, navigationItem.rx.title)
//            .disposed(by: disposeBag)
        
    }
    
}

extension NicknameViewController {
    private func configureLayout() {
        view.backgroundColor = Color.white
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
         
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
