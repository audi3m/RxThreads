//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhoneViewController: UIViewController {
    
    let viewModel = PhoneViewModel()
    let disposeBag = DisposeBag()
    
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        bind()
    }
}

extension PhoneViewController {

    private func bind() {
        let input = PhoneViewModel.Input(tap: nextButton.rx.tap,
                                         text: phoneTextField.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
        output.validText
            .bind(to: nextButton.rx.title())
            .disposed(by: disposeBag)
        
        output.validation
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.tap
            .bind { _ in
                print("Clicked")
            }
            .disposed(by: disposeBag)
        
//        viewModel.validText
//            .bind(to: nextButton.rx.title()) // 처리
//            .disposed(by: viewModel.disposeBag)
//        
//        let validation = phoneTextField.rx.text.orEmpty
//            .map { $0.count >= 8 }
//        
//        validation // 받는 부분
//            .bind(to: nextButton.rx.isEnabled)
//            .disposed(by: viewModel.disposeBag)
//        
//        nextButton.rx.tap
//            .bind { _ in
//                print("Button clicked")
//            }
//            .disposed(by: viewModel.disposeBag)
    }
    
    private func configureLayout() {
        view.backgroundColor = Color.white
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
