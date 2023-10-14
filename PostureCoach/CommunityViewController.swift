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
    
    let labelMapper = LabelMapper()
    let machines = ["chestpress", "latpulldown", "legextension", "legpress"]
    
    var rankingMine: String = ""
    var rankingToday: [RankingToday] = []
    var rankingBirth: [RankingBirth] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rankingTableView.dataSource = self
        rankingTableView.delegate = self
        
        fetchRankingMine()
        fetchRankingToday()
        fetchRankingBirth()
    }
    
    func fetchRankingMine() {
        let url = "https://pcoachapi.azurewebsites.net/api/ranking/my"
        
        AF.request(url).responseDecodable(of: [RankingMine].self) { response in
            switch response.result {
            case .success(let value):
                if let ranking = value.first?.ranking {
                    self.rankingMine = "\(ranking)위"
                    self.myRankingLabel.text = self.rankingMine
                } else {
                    self.rankingMine = "0위"
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
    
    func fetchRankingBirth() {
        let url = "https://pcoachapi.azurewebsites.net/api/ranking/birth"
        
        AF.request(url).responseDecodable(of: [RankingBirth].self) { response in
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
            return 1
        case 2:
            return rankingBirth.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rankingTableView.dequeueReusableCell(withIdentifier: "rankingcell", for: indexPath)
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            if indexPath.section == 2 && indexPath.row < rankingBirth.count {
                let rowData = rankingBirth[indexPath.row]
                let imageName = rowData.machineName
                imageView.image = UIImage(named: imageName)
            }
        }
        
        if let label = cell.viewWithTag(2) as? UILabel {
            if indexPath.section == 0 && indexPath.row < rankingToday.count {
                let rowData = rankingToday[indexPath.row]
                label.text = rowData.userName
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
                label.text = "\(rowData.exerciseCount)회"
            } else if indexPath.section == 2 && indexPath.row < rankingBirth.count {
                let rowData = rankingBirth[indexPath.row]
                label.text = "\(rowData.exerciseCount)회"
            } else {
                label.text = ""
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "오늘의 순위"
        case 1:
            return "오늘의 운동 횟수 평균(체형별)"
        case 2:
            return "오늘의 운동 횟수 평균(연령별)"
        default:
            return nil
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

struct RankingBirth: Decodable {
    let machineName: String
    let exerciseCount: Int
    
    enum CodingKeys: String, CodingKey {
        case machineName = "machine_name"
        case exerciseCount = "exercise_count"
    }
}


