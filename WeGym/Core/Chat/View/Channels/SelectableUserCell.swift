//
//  SelectableUserCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/25/23.
//

import SwiftUI

struct SelectableUserCell: View {
  let selectableUser: SelectableUser
  
  var body: some View {
    VStack {
      HStack(spacing: 12) {
        CircularProfileImageView(user: selectableUser.user, size: .small)
        
        VStack(alignment: .leading) {
          Text(selectableUser.user.username)
            .font(.system(size: 14, weight: .semibold))
          
          if let fullname = selectableUser.user.fullName {
            Text(fullname)
              .font(.system(size: 14))
          }
        }
        .foregroundColor(.primary)
        
        Spacer()
        
        Image(systemName: selectableUser.isSelected ? "checkmark.circle.fill" : "circle")
          .resizable()
          .scaledToFit()
          .foregroundColor(selectableUser.isSelected ? .blue : .gray)
          .frame(width: 20, height: 20)
          .padding(.trailing)
      }
      .padding(.horizontal)
    }
    .padding(.top)
  }
}

#Preview {
  SelectableUserCell(selectableUser: SelectableUser(user: User.MOCK_USERS_2[0]))
}
