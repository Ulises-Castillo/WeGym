//
//  NotificationCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI

import SwiftUI
import Kingfisher

struct NotificationCell: View {
  @ObservedObject var viewModel: NotificationCellViewModel
  @Binding var notification: Notification2

  var isFollowed: Bool {
    return notification.isFollowed ?? false
  }

  init(notification: Binding<Notification2>) {
    self.viewModel = NotificationCellViewModel(notification: notification.wrappedValue)
    self._notification = notification
  }

  var body: some View {
    HStack {
      if let user = notification.user {
        NavigationLink(value: NotificationsNavigation.profile(user)) {
          CircularProfileImageView(user: user, size: .xSmall)

          HStack {
            Text(user.username)
              .font(.system(size: 14, weight: .semibold)) +

            Text(notification.type.notificationMessage)
              .font(.system(size: 14)) +

            Text(" \(notification.timestamp.timestampString())")
              .foregroundColor(.gray).font(.system(size: 12))
          }
          .multilineTextAlignment(.leading)
        }
      }

      Spacer()

      if notification.type != .follow {
        if let trainingSession = notification.trainingSession {
          NavigationLink(destination: TrainingSessionCell(trainingSession: trainingSession, shouldShowTime: true)) { //TODO: deal with should show time here

            HStack {
              // body parts / workout type
              Text(trainingSession.user?.fullName ?? trainingSession.user?.username ?? "NONE")
              ForEach((trainingSession.focus), id: \.self) { focus in
                Text(" \(focus)   ")
                  .frame(height: 33)
                  .background(Color(.systemBlue))
                  .cornerRadius(6)
              }
            }
          }
        }
      } else {
        Button(action: {
          isFollowed ? viewModel.unfollow() : viewModel.follow()
          notification.isFollowed?.toggle()
        }, label: {
          Text(isFollowed ? "Following" : "Follow")
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 100, height: 32)
            .foregroundColor(isFollowed ? .black : .white)
            .background(isFollowed ? Color.white : Color.blue)
            .cornerRadius(6)
            .overlay(
              RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: isFollowed ? 1 : 0)
            )
        })
      }

    }
    .accentColor(.primary)
    .padding(.horizontal)
  }
}
