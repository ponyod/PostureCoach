//
//  Model.swift
//  PostureCoach
//
//  Created by Youn on 2023/09/28.
//

import Foundation

struct User {
    let userId: String
    let password: String
    let nickname: String
    
    enum CodingKeys:String, CodingKey {
        case userId = "User_id"
    }
}
