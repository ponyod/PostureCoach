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

struct WorkoutReport: Decodable {
    let userId: String
    let machineName: Int
    let exerciseCount: Int
    let exerciseDate: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case machineName = "machine_name"
        case exerciseCount = "exercise_count"
        case exerciseDate = "exercise_date"
    }
}

struct ExerciseLog: Decodable {
    let userId: String
    let machineName: Int
    let exerciseCount: Int
    let exerciseDate: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case machineName = "machine_name"
        case exerciseCount = "exercise_count"
        case exerciseDate = "exercise_date"
    }
}
