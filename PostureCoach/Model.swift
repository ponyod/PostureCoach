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
