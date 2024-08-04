//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PasswordViewController: UIViewController {
    
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let warningLabel = UILabel()
    
    var disposeBag = DisposeBag()
    let emailData = BehaviorSubject<String>(value: "example@gmail.com")
    
    /*
     1. 8자리 이상일 때 true
     2. true일 때 활성화
     3. 다음 버튼 탭 시 화면 전환
     4. descLabel 임시로 추가("8자리 이상 입력해주세요")
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        configureLayout()
        bindData()
    }
    
    private func bindData() {
        
        // 4자리 이상, 초록 & 클릭 가능
        // 4자리 미만, 빨강 & 클릭 불가
        let emailValid = passwordTextField.rx.text.orEmpty
            .map { $0.count >= 8 }
        
        emailValid
            .bind(with: self) { owner, value in
                owner.nextButton.isEnabled = value
                owner.warningLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        emailValid
            .bind(with: self) { owner, value in
                owner.nextButton.backgroundColor = value ? .green : .red
            }
            .disposed(by: disposeBag)
    }
    
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
        view.addSubview(warningLabel)
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        warningLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(warningLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        warningLabel.text = "8자리 이상 입력해주세요"
        
    }
    
}
