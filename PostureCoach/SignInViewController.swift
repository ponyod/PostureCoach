//
//  ViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/09/25.
//

import UIKit
import Alamofire

class SignInViewController: UIViewController {
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpBtn.layer.borderWidth = 2
        signUpBtn.layer.borderColor = UIColor.black.cgColor
        signUpBtn.layer.cornerRadius = 20
    }
    
    // 사용자가 입력한 아이디(userid)와 비밀번호(userpw)를 가져온다
    @IBAction func btnSignIn(_ sender: UIButton) {
        guard let userId = idField.text, let pwString = pwField.text else { return }
        let userPw = SignupViewController().cryptoPassword(pwString)
        
        loginRequest(userid: userId, userpw: userPw) { success, message in
            if success {
                let dataSave = UserDefaults.standard
                dataSave.setValue(userId, forKey: "loggedInUserId")
                dataSave.setValue(userId, forKey: "id")
                
                if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let sceneDelegate = windowScene.delegate as? SceneDelegate {
                            sceneDelegate.window?.rootViewController = tabBarController
                        }
                    }
                }
            } else { return }
        }
    }
    
    func loginRequest(userid: String, userpw: String, completion: @escaping (Bool, String) -> Void) {
        let url = "https://pcoachapi.azurewebsites.net/api/login"
        let parameters: [String: Any] = [
            "user_id": userid,
            "user_pw": userpw
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success(let data):
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let success = json["success"] as? Bool,
                           let message = json["message"] as? String {
                            completion(success, message)
                        } else {
                            completion(false, "서버 응답 데이터 구문 분석 오류")
                        }
                    } catch {
                        completion(false, "데이터 파싱 오류: \(error.localizedDescription)")
                    }
                }
                else {
                    completion(false, "데이터 없음 또는 형식 불일치")
                }
            case .failure(let error):
                completion(false, "요청 실패 또는 네트워크 오류: \(error.localizedDescription)")
            }
            
        }
    }
    
    // 화면 클릭하면 키패드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

