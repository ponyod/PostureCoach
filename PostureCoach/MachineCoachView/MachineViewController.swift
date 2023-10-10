//
//  WebViewTest
//
//  Created by ponyo on 2023/09/28.
//

import UIKit
import CoreML
import Vision

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
}

class MachineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var machineLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var machineImageView: UIImageView!
    @IBOutlet weak var machineTableView: UITableView!
    
    var userImage: UIImage?
    var classification: [VNClassificationObservation]?
    let labelMapper = LabelMapper()
    var selectedLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userImage = userImage {
            userImageView.image = userImage
            makeCircularImageView(userImageView)
        } else {
            fatalError("userImage is nil")
        }
        
        makeCircularImageView(machineImageView)
        
        guard let coreImage = CIImage(image: userImageView.image!) else {
            fatalError("Failed convert CIImage")
        }
        detect(image: coreImage)
        
        self.machineTableView.delegate = self
        self.machineTableView.dataSource = self
        
        print(classification)
    }
    
    // 이미지 원형으로 설정
    func makeCircularImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
    
    // 운동보기 버튼 클릭 시 segue 설정
    @IBAction func showYoutube(_ sender: UIButton) {
        performSegue(withIdentifier: "showWebViewSegue", sender: nil)
    }
    
    // WebViewController로 URL 전송
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebViewSegue" {
            if let webViewController = segue.destination as? WebViewController {
                webViewController.urlString = "https://www.youtube.com/results?search_query=\(machineLabel.text!)+사용법"
            }
        } 
//        else if segue.identifier == "showWebViewSegueTable" {
//            if let cellWebViewController = segue.destination as? CellWebViewController {
//                let labelText = sender as? String
//                cellWebViewController.UrlString = "https://www.youtube.com/results?search_query=\(labelText ?? "테스트")+사용법"
//                print("\(labelText ?? "테스트")입니다")
//            }
//        }
    }
    

    // machineTableView cell 정의
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = machineTableView.dequeueReusableCell(withIdentifier: "machinecell", for: indexPath) as! CustomTableViewCell
        //        guard let cell = machineTableView.dequeueReusableCell(withIdentifier: "machinecell") else {
        //            return UITableViewCell()
        //        }
        
        // classification 배열을 confidence 값에 따라 내림차순으로 정렬
        //        let sortedClassification = classification
        
        // 테이블뷰의 첫 번째 행부터 모든 행에 출력
        cell.cellLabel.text = labelMapper.mapLabel(classification![indexPath.row + 1].identifier)
        cell.cellButton.addTarget(self, action: #selector(openWebView(_:)), for: .touchUpInside)
        cell.cellButton.tag = indexPath.row
        
        //        if let tableLabel = cell.viewWithTag(2) as? UILabel, indexPath.row < 3 {
        //            tableLabel.text = labelMapper.mapLabel(classification![indexPath.row + 1].identifier)
        //        }
        
        // 버튼 액션을 설정
        //        if let tableButton = cell.viewWithTag(3) as? UIButton {
        //            // 해당 버튼의 타겟 메서드에 indexPath 정보를 전달하여 버튼을 클릭할 때 어떤 셀의 버튼인지 알 수 있도록 합니다.
        //            tableButton.addTarget(self, action: #selector(openWebView(_:)), for: .touchUpInside)
        ////            tableButton.tag = indexPath.row // 버튼의 태그에 indexPath.row 값을 저장합니다.
        //        }
        
        return cell
        //        if let classification = self.classification, classification.indices.contains(indexPath.row) {
        //            // classification 배열에서 값을 가져와 설정
        //            cell.textLabel?.text = classification[indexPath.row].identifier
        //        } else {
        //            cell.textLabel?.text = "No Label Found"
        //        }
        
    }
    
    
    // machineTableView cell 개수 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // classification 배열의 개수와 3 중 작은 값을 반환
        return min(classification?.count ?? 0, 3)
    }
    
    // machineTableView cell 버튼 동작 정의
    @objc func openWebView(_ sender: UIButton) {
        // 버튼을 클릭했을 때 실행할 동작
        // sender의 tag에 저장된 indexPath.row 값을 가져옵니다.
        //        let rowIndex = sender.tag
        
        let workoutname = classification![sender.tag + 1].identifier
        print(classification!)
        print(workoutname)
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CellWebViewController") as? CellWebViewController else { fatalError()}
        vc.UrlString = "https://www.youtube.com/results?search_query=\(workoutname)+사용법"
        print(vc.UrlString!)
                
        present(vc, animated: true)
//        if let cellWebViewController = segue.destination as? CellWebViewController {
//            let labelText = sender as? String
//            cellWebViewController.UrlString = "https://www.youtube.com/results?search_query=\(labelText ?? "테스트")+사용법"
//            print("\(labelText ?? "테스트")입니다")
//        }
//        if let cell = sender.superview?.superview as? CustomTableViewCell,
//           let labelText = cell.cellLabel.text {
//            performSegue(withIdentifier: "showWebViewSegueTable", sender: labelText)
//        }
        //        if let classification = self.classification, sender.tag < 3 {
        //            selectedLabel = labelMapper.mapLabel(classification[sender.tag + 1].identifier)
        //            // selectedLabel을 사용하여 원하는 동작을 수행하십시오.
        //            // 예를 들어, 여기에서 세그웨이를 실행할 수 있습니다.
        //            performSegue(withIdentifier: "showWebViewSegueTable", sender: nil)
        //        }
    }
}

// userImage 분류
extension MachineViewController {
    func detect(image: CIImage) {
        do {
            let modelConfig = MLModelConfiguration()
            let coreMLModel = try MachineClassifier(configuration: modelConfig)
            let visionModel = try VNCoreMLModel(for: coreMLModel.model)
            
            let request = VNCoreMLRequest(model: visionModel) { request, error in
                guard error == nil else {
                    fatalError("Failed Request")
                }
                guard let classification = request.results as? [VNClassificationObservation] else {
                    fatalError("Failed convert VNClassificationObservation")
                }
                
                // classification을 confidence 값에 따라 내림차순으로 정렬
                let sortedClassification = classification.sorted(by: { $0.confidence > $1.confidence })
                
                
                // 각 classification에서 identifier(레이블) 값을 추출하여 배열에 저장
                var labels = [String]()
                for item in sortedClassification {
                    labels.append(item.identifier)
                }
                // 첫 번째 라벨을 가져오기
                if let firstLabel = sortedClassification.first?.identifier {
                    self.machineLabel.text = self.labelMapper.mapLabel(firstLabel) //"\(sortedClassification)"//firstLabel
                } else {
                    self.machineLabel.text = "No Label Found"
                }
                
                self.classification = sortedClassification
                
                DispatchQueue.main.async { [weak self] in
                    self?.machineTableView.reloadData() // 테이블뷰를 업데이트
                }
                // labels 배열을 쉼표로 구분하여 문자열로 변환
                //                let resultText = labels.joined(separator: ", ")
                //                var resultText = ""
                //                resultText += "\(classification)"
                
                //                print(classification)
                
                //                self.machineLabel.text = resultText
            }
            let handler = VNImageRequestHandler(ciImage: image)
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}


class LabelMapper {
    // 라벨 매핑 사전
    private let labelMappings: [String: String] = [
        "kettlebell": "케틀벨",
        "latpulldown": "랫풀다운",
        "treadmill": "트레드밀",
        "legextension": "레그익스텐션",
        "legpress": "레그프레스",
        "dumbbell": "덤벨",
        "powerrack": "파워랙",
        "rowing": "로잉머신",
        "chestpress": "체스트프레스",
        "foamroller": "폼롤러",
        "yogaring": "요가링"
    ]
    
    // 원본 라벨을 변환된 라벨으로 매핑하는 함수
    func mapLabel(_ originalLabel: String) -> String {
        // 매핑이 있는 경우 변환된 라벨을 반환하고, 그렇지 않으면 원본 라벨을 그대로 반환
        return labelMappings[originalLabel] ?? originalLabel
    }
}
