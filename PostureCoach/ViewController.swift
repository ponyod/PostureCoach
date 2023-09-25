//
//  ViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/09/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // 사용자가 입력한 아이디(userid)와 비밀번호(userpw)를 가져온다
    @IBAction func btnSignIn(_ sender: UIButton) {
        guard let userid = idField.text, let userpw = pwField.text else { return }
        
        // 로그인 Alert 테스트 코드 *백엔드 작업 후 수정필요
        if isValidLogin(userid: userid, userpw: userpw) {
            showAlert(title: "로그인 성공", message: "성공테스트")
        } else {
            showAlert(title: "로그인 실패", message: "실패테스트")
        }
    }

    // 로그인 검증 테스트 코드 *백엔드 작업 후 수정필요
    func isValidLogin(userid: String, userpw: String) -> Bool {
        return userid == "test" && userpw == "test"
    }
    
    // AlertController 정의
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // 화면 클릭하면 키패드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

