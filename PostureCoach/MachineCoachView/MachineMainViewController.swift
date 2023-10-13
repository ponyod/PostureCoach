//
//  MainViewController.swift
//  WebViewTest
//
//  Created by ponyo on 2023/09/28.
//

import UIKit
import Alamofire

class MachineMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, XMLParserDelegate {
    @IBOutlet weak var contentsLabel: UILabel!
    
    var selectedImage: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        search()
    }
    
    // 카메라 촬영 버튼 정의
    @IBAction func actCamera(_ sender: UIButton) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        present(self.imagePicker, animated: true, completion: nil)
        
        //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //            let imagePicker = UIImagePickerController()
        //            imagePicker.sourceType = .camera
        //            imagePicker.delegate = self
        //            present(imagePicker, animated: true, completion: nil)
        //        } else {
        //            // 카메라 사용 불가능한 경우 경고 메시지 표시
        //            let alertController = UIAlertController(title: "경고", message: "카메라를 사용할 수 없습니다.", preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        //            alertController.addAction(okAction)
        //            present(alertController, animated: true, completion: nil)
        //        }
    }
    
    // 앨범에서 선택 버튼 정의
    @IBAction func actAlbum(_ sender: UIButton) {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
        //        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
        //            let imagePicker = UIImagePickerController()
        //            imagePicker.sourceType = .photoLibrary
        //            imagePicker.delegate = self
        //            present(imagePicker, animated: true, completion: nil)
        //        } else {
        //            // 앨범 접근 불가능한 경우 경고 메시지 표시
        //            let alertController = UIAlertController(title: "경고", message: "앨범에 접근할 수 없습니다.", preferredStyle: .alert)
        //            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        //            alertController.addAction(okAction)
        //            present(alertController, animated: true, completion: nil)
        //        }
    }
    
    // 이미지 선택이 완료되었을 때 호출되는 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //        if picker.sourceType == .camera {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // 선택한 이미지를 다음 뷰 컨트롤러로 전달하고 다음 화면으로 이동
            let nextViewController = UIStoryboard(name: "MachineCoachView", bundle: nil).instantiateViewController(withIdentifier: "MachineViewController") as! MachineViewController
            nextViewController.userImage = selectedImage
            navigationController?.pushViewController(nextViewController, animated: true)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택이 취소되었을 때 호출되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func search() {
        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        let encoding = String.Encoding(rawValue: rawEncoding)
        
        let strURL = "https://suggestqueries.google.com/complete/search?hl=ko&ds=yt&q=운동시작&client=firefox"
        let alamo = AF.request(strURL)
        alamo.response(){ response in
//            print(response)
            guard let data = response.data else { return }
            guard let str = String(data: data, encoding: encoding) else { return }
            
//            print(str)
            let str1 = str.split(separator: "[")
            let str2 = str1[1].split(separator: "]")
//            print(str2[0])
            let str3 = str2[0].split(separator: ",")
            
            var labelText = ""
            for i in 0..<5 {
                labelText += "#\(str3[i])"
                if i < 4 {
                    labelText += " "
                }
            }
            print(labelText)
            self.contentsLabel.text = labelText
//            for keyword in str3 {
//                print(keyword)
//                self.suggestions.append(String(keyword))
//            }
        }
//        contentsLabel.text = self.suggestions[1]
    }
}
