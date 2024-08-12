//
//  SignInViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignInViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let signInButton = PointButton(title: "로그인")
    let signUpButton = UIButton()
    
    let disposeBag = DisposeBag()
    let viewModel = SignInViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        signInButton.addTarget(self, action: #selector(signInButtonClicked), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonClicked), for: .touchUpInside)
        
        rxBind()
    }
    
    private func rxBind() {
        
        let input = SignInViewModel.Input(tap: signInButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.text
            .map { joke in
                return joke.joke
            }
            .drive(emailTextField.rx.text)
//            .subscribe(with: self, onNext: { owner, value in
//                <#code#>
//            }, onError: { <#Object#>, <#any Error#> in
//                <#code#>
//            }, onCompleted: { <#Object#> in
//                <#code#>
//            }, onDisposed: { <#Object#> in
//                <#code#>
//            })
            .disposed(by: disposeBag)
        
        output.text
            .map { value in
                return "농담: \(value.id)"
            }
            .drive(navigationItem.rx.title)
//            .bind(to: emailTextField.rx.text)
            .disposed(by: disposeBag)
        
//        output.text
//            .drive(emailTextField.rx.text)
//            .disposed(by: disposeBag)
//        
//        output.text
//            .drive(navigationItem.rx.title)
//            .disposed(by: disposeBag)
        
    }
    
    @objc func signInButtonClicked() {
        
    }
    
    @objc func signUpButtonClicked() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    func configure() {
        signUpButton.setTitle("회원이 아니십니까?", for: .normal)
        signUpButton.setTitleColor(Color.black, for: .normal)
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
}
