//
//  CommunityViewController.swift
//  PostureCoach
//
//  Created by ponyo on 2023/10/13.
//

import UIKit
import Alamofire
import Foundation

class CommunityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var myRankingLabel: UILabel!
    @IBOutlet weak var rankingTableView: UITableView!
    @IBOutlet weak var rankingView: UIView!
    
    let labelMapper = LabelMapper()
    let machines = ["chestpress", "latpulldown", "legextension", "legpress"]
    let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId")
    
    var rankingMine: String = ""
    var rankingToday: [RankingToday] = []
    var rankingPhysical: [RankingPhysical] = []
    var rankingBirth: [RankingBirth] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rankingTableView.layer.borderWidth = 1
        rankingTableView.layer.borderColor = UIColor.black.cgColor
        
        rankingView.layer.borderWidth = 1
        rankingView
            .layer.borderColor = UIColor.black.cgColor
        
        rankingTableView.dataSource = self
        rankingTableView.delegate = self
        
        fetchRankingMine()
        fetchRankingToday()
        fetchRankingPhysical()
        fetchRankingBirth()
    }
    
    func fetchRankingMine() {
        let url = "https://pcoachapi.azurewebsites.net/api/ranking/my"
        let parameters: [String: Any] = ["loggedInUserId": loggedInUserId!]
        
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: [RankingMine].self) { response in
            switch response.result {
            case .success(let value):
                if let ranking = value.first?.ranking {
                    self.rankingMine = "\(ranking)"
                    self.myRankingLabel.text = self.rankingMine
                } else {
                    self.rankingMine = "0"
                    self.myRankingLabel.text = self.rankingMine
                }
            case .failure(let error):
                // 에러 핸들링
                if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                    print("Error: \(errorString)")
                } else {
                    print(error)
                }
            }
        }
    }
    
    func fetchRankingToday() {
        let url = "https://pcoachapi.azurewebsites.net/api/ranking/today"
        
        AF.request(url).responseDecodable(of: [RankingToday].self) { response in
            switch response.result {
            case .success(let value):
                self.rankingToday = value
                self.rankingTableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchRankingPhysical() {
        let url = "https://pcoachapi.azurewebsites.net/api/ranking/physical"
        let parameters: [String: Any] = ["loggedInUserId": loggedInUserId!]
        
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: [RankingPhysical].self) { response in
            switch response.result {
            case .success(let value):
                self.rankingPhysical = value
                print(self.rankingPhysical)
                self.rankingTableView.reloadData()
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func fetchRankingBirth() {
        let url = "https://pcoachapi.azurewebsites.net/api/ranking/birth"
        let parameters: [String: Any] = ["loggedInUserId": loggedInUserId!]
        
        AF.request(url, method: .get, parameters: parameters).responseDecodable(of: [RankingBirth].self) { response in
            switch response.result {
            case .success(let value):
                self.rankingBirth = value
                self.rankingTableView.reloadData()
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return rankingPhysical.count
        case 2:
            return rankingBirth.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rankingTableView.dequeueReusableCell(withIdentifier: "rankingcell", for: indexPath)
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if indexPath.section == 1 && indexPath.row < rankingPhysical.count {
                let rowData = rankingPhysical[indexPath.row]
                let imageName = rowData.machineName
                imageView.image = UIImage(named: imageName)
            } else if indexPath.section == 2 && indexPath.row < rankingBirth.count {
                let rowData = rankingBirth[indexPath.row]
                let imageName = rowData.machineName
                imageView.image = UIImage(named: imageName)
            }
        }
        
        if let label = cell.viewWithTag(2) as? UILabel {
            if indexPath.section == 0 && indexPath.row < rankingToday.count {
                let rowData = rankingToday[indexPath.row]
                label.text = rowData.userName
            } else if indexPath.section == 1 && indexPath.row < rankingPhysical.count {
                let rowData = rankingPhysical[indexPath.row]
                label.text = labelMapper.mapLabel(rowData.machineName)
            } else if indexPath.section == 2 && indexPath.row < rankingBirth.count {
                let rowData = rankingBirth[indexPath.row]
                label.text = labelMapper.mapLabel(rowData.machineName)
            } else {
                label.text = ""
            }
        }
        
        if let label = cell.viewWithTag(3) as? UILabel {
            if indexPath.section == 0 && indexPath.row < rankingToday.count {
                let rowData = rankingToday[indexPath.row]
                label.text = "\(rowData.exerciseCount)"
            } else if indexPath.section == 1 && indexPath.row < rankingPhysical.count {
                let rowData = rankingPhysical[indexPath.row]
                label.text = "\(rowData.exerciseCount)"
            } else if indexPath.section == 2 && indexPath.row < rankingBirth.count {
                let rowData = rankingBirth[indexPath.row]
                label.text = "\(rowData.exerciseCount)"
            } else {
                label.text = ""
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "전체 순위"
        case 1:
            return "나와 비슷한 체형의 사람들 운동횟수"
        case 2:
            return "나와 비슷한 연령의 사람들 운동횟수"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let font = UIFont(name: "Apple SD 산돌고딕 Neo", size: 20)
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = font
            header.textLabel?.textColor = .black
            header.textLabel?.frame = CGRect(x: 16, y: 8, width: tableView.bounds.size.width, height: 24)
        }
    }
}

struct RankingMine: Decodable {
    let ranking: Int
}

struct RankingToday: Decodable {
    let userName: String
    let exerciseCount: Int
    
    enum CodingKeys: String, CodingKey {
        case userName = "user_name"
        case exerciseCount = "exercise_count"
    }
}

struct RankingPhysical: Decodable {
    let machineName: String
    let exerciseCount: Double
    
    enum CodingKeys: String, CodingKey {
        case machineName = "machine_name"
        case exerciseCount = "exercise_count"
    }
}

struct RankingBirth: Decodable {
    let machineName: String
    let exerciseCount: Double
    
    enum CodingKeys: String, CodingKey {
        case machineName = "machine_name"
        case exerciseCount = "exercise_count"
    }
}


