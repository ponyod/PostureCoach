//
//  MainViewController.swift
//  WebViewTest
//
//  Created by ponyo on 2023/09/28.
//

import UIKit

class MachineMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedImage: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        // Do any additional setup after loading the view.
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
        //        } else if picker.sourceType == .photoLibrary {
        //            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        //                // 선택한 이미지를 미리 보여주는 화면으로 전달하고 해당 화면으로 이동
        //                let previewViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        //                previewViewController.selectedImage = selectedImage
        //                navigationController?.pushViewController(previewViewController, animated: true)
        //            }
        //        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택이 취소되었을 때 호출되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // 다음 view controller로 이동하는 메서드
    //    func moveToNextViewController() {
    //        if let selectedImage = self.selectedImage {
    //            // 사진을 선택한 경우, 다음 view controller로 이동
    //            let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
    //            nextViewController.userImage = selectedImage
    //            navigationController?.pushViewController(nextViewController, animated: true)
    //            //            performSegue(withIdentifier: "showMachineSegue", sender: selectedImage)
    //        } else {
    //            // 취소한 경우, 다음 view controller로 이동하지 않음
    //            // 이 부분에서 다음 view controller로 이동하지 않는 처리를 수행하거나 다른 동작을 수행할 수 있습니다.
    //        }
    //    }
    
    // 세그웨이를 통해 데이터 전달
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "showMachineSegue" {
    //            if let nextViewController = segue.destination as? ViewController {
    //                if let selectedImage = sender as? UIImage {
    //                    nextViewController.userImage = selectedImage
    //                }
    //            }
    //        }
    //    }
}
