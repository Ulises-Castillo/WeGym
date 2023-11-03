//
//  NotificationType.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import Foundation

import Foundation

enum NotificationType: Int, Codable {
    case like
    case comment
    case follow

    var notificationMessage: String {
        switch self {
        case .like: return " liked one of workouts."
        case .comment: return " commented on one of your workouts."
        case .follow: return " started following you."
        }
    }
}
