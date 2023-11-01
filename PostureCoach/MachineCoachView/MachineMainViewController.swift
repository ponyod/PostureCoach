//
//  MainViewController.swift
//  WebViewTest
//
//  Created by ponyo on 2023/09/28.
//

import UIKit
import Alamofire

class MachineMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, XMLParserDelegate {

    var content: String?
    var selectedImage: UIImage?
    let imagePicker = UIImagePickerController()
    var tagStringArray: [String] = []
    var tagButtonArray = [UIButton]()
    
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var tagListView: UIView!
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userName = UserDefaults.standard.value(forKey: "name")
        if let userName = userName {
            contentsLabel.text = "\(userName)님을 위한 추천"
        }
        
        self.imagePicker.delegate = self
        
        fetchContent()
    }
    
    // 카메라 촬영 버튼 정의
    @IBAction func actCamera(_ sender: UIButton) {
        print("카메라 버튼")
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    // 앨범에서 선택 버튼 정의
    @IBAction func actAlbum(_ sender: UIButton) {
        print("앨범 버튼")
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    // 이미지 선택이 완료되었을 때 호출되는 메서드
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MachineViewController") as? MachineViewController else { fatalError() }
            vc.userImage = selectedImage
            navigationController?.pushViewController(vc, animated: true)
            
            // 선택한 이미지를 다음 뷰 컨트롤러로 전달하고 다음 화면으로 이동
            
//            let nextViewController = UIStoryboard(name: "MachineCoachView", bundle: nil).instantiateViewController(withIdentifier: "MachineViewController") as! MachineViewController
//            nextViewController.userImage = selectedImage
//            navigationController?.pushViewController(nextViewController, animated: true)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 선택이 취소되었을 때 호출되는 메서드
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchContent() {
        let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId")
        let labelMapper = MachineViewController().labelMapper
        let url = "https://pcoachapi.azurewebsites.net/api/contents"
        let parameters: [String: Any] = ["loggedInUserId": loggedInUserId!]
        
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: [Content].self) { response in
            switch response.result {
            case .success(let value):
                if let machineName = value.first?.machineName {
                    self.content = labelMapper.mapLabel(machineName)
                } else {
                    self.content = "운동시작"
                }
                self.search()
            case .failure(let error):
                if let data = response.data, let errorString = String(data:data, encoding: .utf8) {
                    print("Error: \(errorString)")
                } else {
                    print(error)
                }
            }
        }
        
    }
    
    func search() {
        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        let encoding = String.Encoding(rawValue: rawEncoding)
        
        if let content = content {
            let strURL = "https://suggestqueries.google.com/complete/search?hl=ko&ds=yt&q=\(content)&client=firefox"
            let alamo = AF.request(strURL)
            alamo.response(){ response in
                guard let data = response.data else { return }
                guard let str = String(data: data, encoding: encoding) else { return }
                
                let str1 = str.split(separator: "[")
                let str2 = str1[1].split(separator: "]")
                let str3 = str2[0].split(separator: ",")
                
                for i in 0..<4 {
                    let keyword = str3[i].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "") // 따옴표 제거 및 앞뒤 공백 제거
                    self.tagStringArray.append("\(keyword)")
                }
                self.initTagView()
            }
        } else { return }
    }
    
    private func initTagView() {
        tagButtonArray = tagStringArray.map { createButton(with: $0) }
        tagButtonArray.forEach {
            $0.addTarget(self, action: #selector(touchTagButton), for: .touchUpInside)
        }
        
        let frame = CGRect(x: 0, y: 0, width: tagListView.frame.width, height: tagListView.frame.height)
        let tagView = UIView(frame: frame)
        attachTagButtons(at: tagView, tagButtonArray)
        
        tagListView.addSubview(tagView)
        tagListViewHeight.constant = tagView.frame.height
    }
    
    private func createButton(with title: String) -> UIButton {
        let font = UIFont(name: "Apple SD 산돌고딕 Neo", size: 17)!
        let fontAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let fontSize = title.size(withAttributes: fontAttributes)
        
        let tag = UIButton(type: .custom)
        tag.setTitle(title, for: .normal)
        tag.titleLabel?.font = font
        tag.setTitleColor(.black, for: .normal)
        tag.layer.borderColor = UIColor.black.cgColor
        tag.layer.borderWidth = 1
        tag.layer.cornerRadius = 14
        tag.backgroundColor = .white
        tag.frame = CGRect(x: 0, y: 0, width: fontSize.width + 13.0, height: fontSize.height + 13.0)
        return tag
    }
    
    private func attachTagButtons(at view: UIView, _ tagButtons: [UIButton]) {
        var lineCount: CGFloat = 1
        let marginX: CGFloat = 10
        let marginY: CGFloat = 5
        
        var positionX: CGFloat = 0
        var positionY: CGFloat = 0
        
        for (index, tagButton) in tagButtons.enumerated() {
            tagButton.tag = index
            tagButton.frame = CGRect(x: positionX, y: positionY, width: tagButton.frame.width, height: tagButton.frame.height)
            view.addSubview(tagButton)
            
            if index < tagButtons.count - 1 {
                positionX += tagButton.frame.width + marginX
                
                if positionX + tagButtons[index + 1].frame.width > view.frame.width {
                    positionX = 0
                    positionY += tagButton.frame.height + marginY
                    lineCount += 1
                }
            }
        }
        
        let height = view.subviews.first?.frame.height ?? 0
        let margins: CGFloat = (lineCount - 1) * marginY
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (lineCount * height) + margins)
    }
    
    @objc func touchTagButton(sender: UIButton) {
        if let keyword = sender.titleLabel?.text {
            let urlString = "https://www.youtube.com/results?search_query=\(keyword)"
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ContentsWebViewController") as? ContentsWebViewController else { fatalError() }
            vc.url = urlString
            present(vc, animated: true)
        }
    }
}

struct Content: Decodable {
    let machineName: String
}
