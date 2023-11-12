//
//  PersonalRecordFlex.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/11/23.
//

import SwiftUI

struct PersonalRecordFlex: View {

  let gold = UIColor(red: 252.0/255.0, green: 194.0/255.0, blue: 0, alpha: 1.0)
  let personalRecord: PersonalRecord

  var weight: String {
    guard let weight = personalRecord.weight else { return "" }
    return "\(weight)"
  }

  var reps: Int {
    guard let reps = personalRecord.reps else { return 0 }
    return reps
  }

  var str: String {
    if personalRecord.category == "Calesthenics" {
      return "\(reps)"
    } else if reps > 1 {
      return "\(weight)x\(reps)"
    } else {
      return weight
    }
  }

  var body: some View {
    HStack {
      Text(personalRecord.type)
        .frame(width: (UIScreen.main.bounds.width/3) - 21, height: 24)
        .background(Color(.systemGray2))
        .cornerRadius(6)
        .fontWeight(.semibold)
        .foregroundColor(.white)

      Text(str)
        .frame(width: (UIScreen.main.bounds.width/3) - 21, height: 24)
        .background(Color(.systemGray2))
        .cornerRadius(6)
        .fontWeight(.semibold)
        .foregroundColor(.white)

      Image(systemName: "trophy.fill")
        .resizable()
        .frame(width: (UIScreen.main.bounds.width/11) - 15, height: 21)
        .scaledToFill()
        .background(.clear)
        .fontWeight(.semibold)
        .foregroundColor(Color(gold))
        .padding(.leading, 1)
    }
    .font(.system(size: 12, weight: .regular, design: .rounded))

  }
}

//#Preview {
//  PersonalRecordFlex(personalRecord: PersonalRecord(id: "", category: "", type: "Bench", ownerUid: "", timestamp: Time, notes:))
//}

