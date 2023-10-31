//
//  SignupViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/09/26.
//

import UIKit
import CryptoKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwConfirmTextField: UITextField!
    
    @IBOutlet weak var nameCheckLabel: UILabel!
    @IBOutlet weak var idCheckLabel: UILabel!
    @IBOutlet weak var pwCheckLabel: UILabel!
    @IBOutlet weak var pwConfirmCheckLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.delegate = self
        nameTextField.delegate = self
        pwTextField.delegate = self
        pwConfirmTextField.delegate = self
        
        // 처음에는 모든 라벨을 숨김 상태로 설정
        idCheckLabel.isHidden = true
        nameCheckLabel.isHidden = true
        pwCheckLabel.isHidden = true
        pwConfirmCheckLabel.isHidden = true
        
        idTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwConfirmTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        btnNext.isEnabled = false
        
    }
    
    @objc func textFieldDidChange() {
        if validateID(), validateName(), validatePassword(), validatePasswordConfirmation() {
            btnNext.isEnabled = true
        } else {
            btnNext.isEnabled = false
        }
    }
    
    // 회원가입 로직 구현 *백엔드 작업 후 수정필요
    @IBAction func btnNext(_ sender: UIButton) {
        guard let userId = idTextField.text,
              let userName = nameTextField.text,
              let userPw = pwTextField.text,
              let userPwConfirm = pwConfirmTextField.text else { return }
        
        if validateID(), validateName(), validatePassword(), validatePasswordConfirmation() {
            
            let cryptoUserPw = cryptoPassword(userPw) // 패스워드 암호화

            if let signupPhysicalVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupPhysicalViewController") as? SignupPhysicalViewController {
                signupPhysicalVC.userId = userId
                signupPhysicalVC.userPw = cryptoUserPw
                signupPhysicalVC.userName = userName
                print("넘겼다")
                navigationController?.pushViewController(signupPhysicalVC, animated: true)
            } else { fatalError() }
        } else {
            showAlert(message: "입력 정보를 다시 확인하세요.")
        }
    }        
    
    // 비밀번호를 SHA256 해시암호화 (CryptoKit)
    func cryptoPassword(_ password: String) -> String {
        if let passwordData = password.data(using: .utf8) {
            let hashed = SHA256.hash(data: passwordData)
            return hashed.compactMap { String(format: "%02x", $0) }.joined()
        }
        return ""
    }
    
    // UITextFieldDelegate을 사용하여 텍스트 필드의 입력을 모니터링
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case idTextField:
            validateID()
        case nameTextField:
            validateName()
        case pwTextField:
            validatePassword()
        case pwConfirmTextField:
            validatePasswordConfirmation()
        default:
            break
        }
    }
    
    // 이름 유효성 검사
    func validateName() -> Bool {
        if let name = nameTextField.text, !name.isEmpty {
            nameCheckLabel.isHidden = true
            return true
        } else {
//            nameCheckLabel.isHidden = false
//            nameCheckLabel.text = "이름을 입력하세요."
            return false
        }
    }
    
    // 아이디 유효성 검사
    func validateID() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if let userid = idTextField.text, !userid.isEmpty {
            if emailTest.evaluate(with: userid) {
                idCheckLabel.isHidden = true
                return true
            } else {
                idCheckLabel.isHidden = false
                idCheckLabel.text = "유효한 이메일을 입력하세요."
                return false
            }
        } else {
//            idCheckLabel.isHidden = false
//            idCheckLabel.text = "아이디를 입력하세요."
            return false
        }
    }
    
    // 비밀번호 유효성 검사
    func validatePassword() -> Bool {
        if let userpw = pwTextField.text, !userpw.isEmpty {
            let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$" // 8자 이상 영문과 숫자 조합
            
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            if passwordTest.evaluate(with: userpw) {
                pwCheckLabel.isHidden = true
                return true
            } else {
                pwCheckLabel.isHidden = false
                pwCheckLabel.text = "비밀번호는 8자 이상, 영문과 숫자 포함"
                return false
            }
        } else {
//            pwCheckLabel.isHidden = false
//            pwCheckLabel.text = "비밀번호를 입력하세요."
            return false
        }
    }
    
    // 비밀번호 확인 유효성 검사
    func validatePasswordConfirmation() -> Bool {
        if let userpwConfirm = pwConfirmTextField.text, !userpwConfirm.isEmpty {
            if userpwConfirm == pwTextField.text {
                pwConfirmCheckLabel.isHidden = true
                return true
            } else {
                pwConfirmCheckLabel.isHidden = false
                pwConfirmCheckLabel.text = "비밀번호가 일치하지 않습니다."
                return false
            }
        } else {
//            pwConfirmCheckLabel.isHidden = false
//            pwConfirmCheckLabel.text = "비밀번호를 다시 입력하세요."
            return false
        }
    }
    
    // AlertController 정의
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // 화면 클릭하면 키패드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
