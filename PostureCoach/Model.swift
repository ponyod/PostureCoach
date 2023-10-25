//
//  Model.swift
//  PostureCoach
//
//  Created by Youn on 2023/09/28.
//

import Foundation

struct User {
    let userId: String
    let userPw: String
    let userName: String
    let height: Int
    let weight: Int
    let gender: String
    let birth: String
    
    enum CodingKeys:String, CodingKey {
        case userId = "user_id"
        case userPw = "user_pw"
        case userName = "user_name"
    }
}
