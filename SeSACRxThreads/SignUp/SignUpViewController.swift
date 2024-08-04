//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum RxError: Error {
    case invalidEmail
}

class SignUpViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let validationButton = UIButton()
    let nextButton = PointButton(title: "다음")
    
    let emailData = BehaviorSubject<String>(value: "example@gmail.com")
    //    let emailData = PublishSubject<String>()
    let basicColor = Observable.just(UIColor.systemGreen)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        configureLayout()
        configure()
        bindData()
        validation()
    }
    
    private func validation() {
        // 4자리 이상, 초록 & 클릭 가능
        // 4자리 미만, 빨강 & 클릭 불가
        let emailValid = emailTextField.rx.text.orEmpty
            .map { $0.count >= 4 }
            .share(replay: 1)
        
        emailValid
            .bind(with: self) { owner, value in
                let color: UIColor = value ? .systemGreen : .systemRed
                owner.nextButton.backgroundColor = color
                owner.validationButton.isHidden = !value
            }
            .disposed(by: disposeBag)
        
        emailValid
            .bind(to: nextButton.rx.isEnabled, validationButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        emailValid
            .map { !$0 }
            .bind(to: validationButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        emailValid
            .bind(with: self) { owner, value in
                owner.nextButton.backgroundColor = value ? .green : .red
                owner.emailTextField.layer.borderColor = value ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor
            }
            .disposed(by: disposeBag)
    }
    
    private func testPublishSubject() {
        let example = PublishSubject<String>()
        
        example.onNext("a")
        example.onNext("b")
        example.onError(RxError.invalidEmail)
        
        example
            .subscribe { value in
                print("publish - \(value)")
            } onError: { error in
                print("error - \(error)")
            } onCompleted: {
                print("completed")
            } onDisposed: {
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        example.onNext("c")
        example.onCompleted() // ex) 서버통신
        example.onError(RxError.invalidEmail)
        example.onNext("d")
    }
    
    private func bindData() {
        testPublishSubject()
        
        validationButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.emailData.onNext("\(Int.random(in: 10000...99999))@b.com")
            }
            .disposed(by: disposeBag)
        
        // 그대로 전달
        basicColor
            .bind(to: nextButton.rx.backgroundColor,
                  emailTextField.rx.textColor,
                  emailTextField.rx.tintColor
            )
            .disposed(by: disposeBag)
        
        // 변환해서 사용
        basicColor
            .map { $0.cgColor }
            .bind(to: emailTextField.layer.rx.borderColor)
            .disposed(by: disposeBag)
        
        emailData
            .bind(to: emailTextField.rx.text)
        //            .subscribe(with: self) { owner, value in
        //                owner.emailTextField.text = value
        //            }
            .disposed(by: disposeBag)
        
        
        nextButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}

extension SignUpViewController {
    
    func configure() {
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
}
