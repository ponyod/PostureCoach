//
//  AccountSettingViewController.swift
//  PostureCoach
//
//  Created by Youn on 2023/10/29.
//

import UIKit
import CryptoKit
import Alamofire

class AccountSettingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var pwConfirmTextField: UITextField!
    
    @IBOutlet weak var nameCheckLabel: UILabel!
    @IBOutlet weak var pwCheckLabel: UILabel!
    @IBOutlet weak var pwConfirmCheckLabel: UILabel!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var heightCheckLabel: UILabel!
    @IBOutlet weak var weightCheckLabel: UILabel!
    @IBOutlet weak var genderCheckLabel: UILabel!
    @IBOutlet weak var birthCheckLabel: UILabel!
    
    @IBOutlet weak var showGenderPicker: UITextField!
    @IBOutlet weak var showBirthPicker: UITextField!
    
    var userName: String?
    var userPw: String?
    
    let gender = ["남성", "여성"]
    let genderPicker = UIPickerView()
    var userId = UserDefaults.standard.string(forKey: "loggedInUserId")
    var userInfo : [AccountInfo] = []
    var editUserInfo : [EditInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
        nameTextField.delegate = self
        pwTextField.delegate = self
        pwConfirmTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
        
        // 처음에는 모든 라벨을 숨김 상태로 설정
        nameCheckLabel.isHidden = true
        pwCheckLabel.isHidden = true
        pwConfirmCheckLabel.isHidden = true
        heightCheckLabel.isHidden = true
        weightCheckLabel.isHidden = true
        genderCheckLabel.isHidden = true
        birthCheckLabel.isHidden = true
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        pwConfirmTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        heightTextField.addTarget(self, action: #selector(updateButtonStatus), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(updateButtonStatus), for: .editingChanged)
        
        createDatePicker()
        createPickerView()
        
        btnConfirm.isEnabled = false
        self.tabBarController?.tabBar.isHidden = true;
    }
    

    @objc func textFieldDidChange() {
        if validateName(), validatePassword(), validatePasswordConfirmation() {
            btnConfirm.isEnabled = true
        } else {
            btnConfirm.isEnabled = false
        }
    }
    
    func loadUserInfo(){
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
            let url = "https://pcoachapi.azurewebsites.net/api/userInfo?loggedInUserId=\(loggedInUserId)"
            
            AF.request(url).responseDecodable(of: [AccountInfo].self) { response in
                    switch response.result {
                    case .success(let result):
                        if let userInfo = result.first {
                            self.userId = userInfo.userId
                            self.userPw = userInfo.userPw
                            self.nameTextField.text =
                            "\(userInfo.userName)"
                            self.heightTextField.text = "\(userInfo.height)"
                            self.weightTextField.text = "\(userInfo.weight)"
                            self.showGenderPicker.text = userInfo.gender
                            self.showBirthPicker.text = userInfo.birth
                            print(userInfo)
                        }
                    case .failure(let error):
                        print("\(error) 처리할 수 없음")
                    }
            }
            
        } else {
            // UserDefaults에서 사용자 아이디를 찾을 수 없는 경우 예외 처리
            print("User ID not found in UserDefaults")
        }
    }
    
    func editUserInfo(editInfo: AccountInfo, completion: @escaping (Bool) -> Void) {
        let url = "https://pcoachapi.azurewebsites.net/api/editInfo"
        
        let params:Parameters = [
            "user_id": editInfo.userId,
            "user_pw": editInfo.userPw,
            "user_name": editInfo.userName,
            "height": editInfo.height,
            "weight": editInfo.weight,
            "gender": editInfo.gender,
            "birth": editInfo.birth
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            guard let result = response.value else {
                print("nil")
                return
            }
            print(result)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let replacementStringCharacterSet = CharacterSet(charactersIn: string)
        
//        if textField == showGenderPicker && !string.isEmpty {
//            genderCheckLabel.isHidden = true
//        }
        
        if textField == heightTextField || textField == weightTextField {
            if !allowedCharacterSet.isSuperset(of: replacementStringCharacterSet) && !string.isEmpty {
                if textField == heightTextField {
                    heightCheckLabel.text = "숫자만 입력하세요."
                    heightCheckLabel.isHidden = false
                } else if textField == weightTextField {
                    weightCheckLabel.text = "숫자만 입력하세요."
                    weightCheckLabel.isHidden = false
                }
                return false
            } else {
                if textField == heightTextField {
                    heightCheckLabel.isHidden = true
                } else if textField == weightTextField {
                    weightCheckLabel.isHidden = true
                }
                return true
            }
        }
        
//        if textField == showGenderPicker && !string.isEmpty {
//            genderCheckLabel.isHidden = true
//        }
        return true
    }
    
    func createPickerView() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        showGenderPicker.inputView = genderPicker
        dismissPickerView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        showGenderPicker.text = gender[row]
        updateButtonStatus()
//        genderCheckLabel.isHidden = true
    }
    
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(doneButton(sender: )))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        showGenderPicker.inputAccessoryView = toolBar
        showBirthPicker.inputAccessoryView = toolBar
    }
    
    @objc func doneButton(sender: Any) {
        self.view.endEditing(true)
    }
    
    func createDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko-KR")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // showBirthPicker의 inputView로 datePicker 설정
        showBirthPicker.inputView = datePicker
        
        // date picker의 값이 변경될 때 텍스트 필드에 반영
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        dismissPickerView()
    }
    
    
    @objc func updateButtonStatus() {
        guard let isHeightValid = heightTextField.text?.isEmpty,
        let isWeightValid = weightTextField.text?.isEmpty,
        let isGenderValid = showGenderPicker.text?.isEmpty,
        let isBirthValid = showBirthPicker.text?.isEmpty else { return }

        if !isHeightValid && !isWeightValid && !isGenderValid && !isBirthValid {
            btnConfirm.isEnabled = true
        } else {
            btnConfirm.isEnabled = false
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        showBirthPicker.text = dateFormatter.string(from: sender.date)
        updateButtonStatus()
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
    
    @IBAction func btnConfirm(_ sender: Any) {
        guard let userId = userId,
              let userPw = pwTextField.text,
              let userName = nameTextField.text,
              let heightString = heightTextField.text,
              let height = Int(heightString),
              let weightString = weightTextField.text,
              let weight = Int(weightString),
              let gender = showGenderPicker.text,
              let birth = showBirthPicker.text
        else { return print("실행불가")}
        print(userPw)
        print("버튼 눌림1")
        
        let editInfo = AccountInfo(userId: userId, userPw: userPw, userName: userName, height: height, weight: weight, gender: gender, birth: birth)
        print("\(editInfo) 출력")
        
        if heightCheckLabel.isHidden == false || weightCheckLabel.isHidden == false {
            AccountSettingViewController().showAlert(message: "입력 정보를 다시 확인하세요.")
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        editUserInfo(editInfo: editInfo) { success in
            if success {
                print("User Info edited successfully")
            } else {
                print("Failed to add user")
            }
        }
    }
    
}

