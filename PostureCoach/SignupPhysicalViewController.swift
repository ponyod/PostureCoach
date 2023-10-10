//
//  SignupPhysicalViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/10/10.
//

import UIKit

class SignupPhysicalViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let gender = ["남성", "여성"]
    
    @IBOutlet weak var showGenderPicker: UITextField!
    @IBOutlet weak var showBirthPicker: UITextField!
    
    let genderPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatePicker()
        createPickerView()
//        dismissPickerView()
    }
    
    func createPickerView() {
        genderPicker.delegate = self
        showGenderPicker.inputView = genderPicker
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
    }
    
//    func dismissPickerView() {
//        let toolBar = UIToolbar()
//        toolBar.sizeToFit()
//        let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.action))
//        toolBar.setItems([button], animated: true)
//        toolBar.isUserInteractionEnabled = true
//        showGenderPicker.inputAccessoryView = toolBar
//        showBirthPicker.inputAccessoryView = toolBar
//    }
    
    @objc func action() {
        showGenderPicker.resignFirstResponder() // 피커 뷰를 닫습니다.
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
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        showBirthPicker.text = dateFormatter.string(from: sender.date)
    }
    
    // 화면 클릭하면 키패드 내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
