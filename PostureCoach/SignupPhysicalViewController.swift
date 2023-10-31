//
//  SignupPhysicalViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/10/10.
//

import UIKit
import Alamofire

class SignupPhysicalViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var btnSignUp: UIButton!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var heightCheckLabel: UILabel!
    @IBOutlet weak var weightCheckLabel: UILabel!
    @IBOutlet weak var genderCheckLabel: UILabel!
    @IBOutlet weak var birthCheckLabel: UILabel!
    
    var userName: String?
    var userId: String?
    var userPw: String?
    
    let gender = ["남성", "여성"]
    
    @IBOutlet weak var showGenderPicker: UITextField!
    @IBOutlet weak var showBirthPicker: UITextField!
    
    let genderPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heightTextField.delegate = self
        weightTextField.delegate = self
        
        heightCheckLabel.isHidden = true
        weightCheckLabel.isHidden = true
        genderCheckLabel.isHidden = true
        birthCheckLabel.isHidden = true
        
        btnSignUp.isEnabled = false
        
        createDatePicker()
        createPickerView()
        
        heightTextField.addTarget(self, action: #selector(updateButtonStatus), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(updateButtonStatus), for: .editingChanged)
    }
    
    @IBAction func btnSignUp(_ sender: UIButton) {
        guard let userId = userId,
              let userPw = userPw,
              let userName = userName,
              let heightString = heightTextField.text,
              let height = Int(heightString),
              let weightString = weightTextField.text,
              let weight = Int(weightString),
              let gender = showGenderPicker.text,
              let birth = showBirthPicker.text else { return }
                
        let newUser = User(userId: userId, userPw: userPw, userName: userName, height: height, weight: weight, gender: gender, birth: birth)
        
        if heightCheckLabel.isHidden == false || weightCheckLabel.isHidden == false {
            SignupViewController().showAlert(message: "입력 정보를 다시 확인하세요.")
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        addUser(newUser: newUser) { success in
            if success {
                print("User added successfully")
            } else {
                print("Failed to add user")
            }
        }
    }
    
    func addUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let url = "https://pcoachapi.azurewebsites.net/api/users"
        let params:Parameters = [
            "user_id": newUser.userId,
            "user_pw": newUser.userPw,
            "user_name": newUser.userName,
            "height": newUser.height,
            "weight": newUser.weight,
            "gender": newUser.gender,
            "birth": newUser.birth
        ]
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response { response in
            guard let result = response.value else {
                print("nil")
                return
            }
            print(response)
        }
    }
    
    @objc func updateButtonStatus() {
        guard let isHeightValid = heightTextField.text?.isEmpty,
        let isWeightValid = weightTextField.text?.isEmpty,
        let isGenderValid = showGenderPicker.text?.isEmpty,
        let isBirthValid = showBirthPicker.text?.isEmpty else { return }

        if !isHeightValid && !isWeightValid && !isGenderValid && !isBirthValid {
            btnSignUp.isEnabled = true
        } else {
            btnSignUp.isEnabled = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        let replacementStringCharacterSet = CharacterSet(charactersIn: string)
        
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
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        showBirthPicker.text = dateFormatter.string(from: sender.date)
        updateButtonStatus()
    }
    
    // 화면 클릭하면 키패드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
