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
          NavigationLink{
            TrainingSessionCell(trainingSession: trainingSession,
                                shouldShowTime: true,
                                showLikes: notification.type == .like,
                                showComments: notification.type == .comment,
                                commentsViewMode: notification.type == .comment,
                                notificationCellMode: true) // deal with should show time
              .padding(.top, 13)
            Spacer()
              .navigationTitle(relativeDay(trainingSession.date.dateValue()))
          } label: { //TODO: deal with should show time here
            // body parts / workout type
            HStack { //TOODO: consider showing only first focus, larger font size (just a preview)
              Text(" \(beautifyWorkoutFocuses(focuses: trainingSession.focus).first ?? "")   ")
                .frame(width: 100, height: 32)
                  .background(Color(.systemBlue))
                  .cornerRadius(6)
                  .foregroundColor(.white)
                  .font(.system(size: 14, weight: .bold, design: Font.Design.rounded))
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
