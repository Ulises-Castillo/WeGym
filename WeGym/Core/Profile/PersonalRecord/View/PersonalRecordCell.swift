//
//  PersonalRecordCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI

struct PersonalRecordCell: View {
  @State var isFavorite = false
  @State var isMax = true

  let gold = UIColor(red: 252.0/255.0, green: 194.0/255.0, blue: 0, alpha: 1.0)

  init(isFavorite: Bool = false, isMax: Bool = false) {
    self._isFavorite = State(initialValue: isFavorite)
    self._isMax = State(initialValue: isMax)
  }

  var body: some View {
    HStack {
      // Date (beautified)
      Text("June 2022")
        .frame(width: (UIScreen.main.bounds.width/3.5) - 15, height: 32)
        .background(Color(isFavorite ? .systemBlue : .systemGray2))
        .cornerRadius(6)
        .fontWeight(isMax ? .bold : .light)
        .foregroundColor(.white)

      // PR Type (ex: Bench)
      Text(" Bench   ") //TODO: investigate actual root cause of issue
        .frame(width: (UIScreen.main.bounds.width/3) - 15, height: 32)
        .background(Color(isFavorite ? .systemBlue : .systemGray2))
        .cornerRadius(6)
        .fontWeight(isMax ? .bold : .light)
        .foregroundColor(.white)

      // PR number (245)
      Text(" 245   ") //TODO: investigate actual root cause of issue
        .frame(width: (UIScreen.main.bounds.width/3.5) - 15, height: 32)
        .background(Color(isFavorite ? .systemBlue : .systemGray2))
        .cornerRadius(6)
        .fontWeight(isMax ? .bold : .light)
        .foregroundColor(.white)

      // Fav button
      Button {
        isFavorite.toggle()
      } label: {
        Image(systemName: "star.square.fill") //TODO: investigate actual root cause of issue
          .resizable()
          .frame(width: (UIScreen.main.bounds.width/8) - 15, height: 32)
          .background(isFavorite ? Color(gold) : .clear)
          .cornerRadius(6)
          .fontWeight(.semibold)
          .foregroundColor(Color(.systemBlue))
      }
    }
    .font(.system(size: 14, weight: .regular, design: Font.Design.rounded))
  }
}

#Preview {
  PersonalRecordCell()
}
