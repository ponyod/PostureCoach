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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // 사용자가 입력한 아이디(userid)와 비밀번호(userpw)를 가져온다
    @IBAction func btnSignIn(_ sender: UIButton) {
        guard let userid = idField.text, let userpw = pwField.text else { return }
        
        loginRequest(userid: userid, userpw: userpw) { success, message in
            if success {
                let dataSave = UserDefaults.standard
                dataSave.setValue(userid, forKey: "loggedInUserId")
                dataSave.setValue(userid, forKey: "id")
                dataSave.setValue(userpw, forKey: "pw")
                
                if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if let sceneDelegate = windowScene.delegate as? SceneDelegate {
                            sceneDelegate.window?.rootViewController = tabBarController
                        }
                    }
                    print("로그인 성공")
                }
            } else {
                self.showAlert(title: "로그인 실패", message: message)
            }
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
    
    //    // 로그인 검증 테스트 코드 *백엔드 작업 후 수정필요
    //    func isValidLogin(userid: String, userpw: String) -> Bool {
    //        return userid == "test" && userpw == "test"
    //    }
    
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

