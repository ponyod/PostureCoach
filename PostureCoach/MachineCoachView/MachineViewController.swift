//
//  WebViewTest
//
//  Created by ponyo on 2023/09/28.
//

import UIKit
import CoreML
import Vision

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
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
    let machines = ["chestpress", "dumbbell", "foamroller", "kettlebell", "latpulldown", "legextension", "legpress", "powerrack", "rowing", "treadmill", "yogaring"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true // 탭바 히든 처리
        
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
        machineTableView.layer.borderWidth = 1
        machineTableView.layer.borderColor = UIColor.black.cgColor
        
        setMachineImage()
                
    }
    
    func setMachineImage() {
        let imageName = "\(classification?.first?.identifier ?? "yogaring").png"
//        print(imageName)
        machineImageView.image = UIImage(named: imageName)
    }
    
    // 이미지 원형으로 설정
    func makeCircularImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    @IBAction func btnClose(_ sender: UIButton) {
        //self.navigationController?.popToRootViewController(animated: true)
        
        let nextViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        navigationController?.pushViewController(nextViewController, animated: true)
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
    }
    

    // machineTableView cell 정의
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = machineTableView.dequeueReusableCell(withIdentifier: "machinecell", for: indexPath) as! CustomTableViewCell
        let imageName = "\(classification![indexPath.row + 1].identifier).png"
        
        // 테이블뷰의 첫 번째 행부터 모든 행에 출력
        cell.cellImage.image = UIImage(named: imageName)
        cell.cellLabel.text = labelMapper.mapLabel(classification![indexPath.row + 1].identifier)
        cell.cellButton.addTarget(self, action: #selector(openWebView(_:)), for: .touchUpInside)
        cell.cellButton.tag = indexPath.row
        
        return cell
    }
    
    
    // machineTableView cell 개수 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // classification 배열의 개수와 3 중 작은 값을 반환
        return min(classification?.count ?? 0, 3)
    }
    
    // machineTableView cell 버튼 동작 정의
    @objc func openWebView(_ sender: UIButton) {
        let workoutname = labelMapper.mapLabel(classification![sender.tag + 1].identifier)
        print(classification!)
        print(workoutname)
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CellWebViewController") as? CellWebViewController else { fatalError()}
        vc.UrlString = "https://www.youtube.com/results?search_query=\(workoutname)+사용법"
        print(vc.UrlString!)
                
        present(vc, animated: true)
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
                    self.machineLabel.text = self.labelMapper.mapLabel(firstLabel)
                } else {
                    self.machineLabel.text = "No Label Found"
                }
                
                self.classification = sortedClassification
                
                DispatchQueue.main.async { [weak self] in
                    self?.machineTableView.reloadData() // 테이블뷰를 업데이트
                }
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
