//
//  PersonalRecordCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI

struct PersonalRecordCell: View {
  @State var personalRecord: PersonalRecord
  @State var showingEditPersonalRecordView = false
  @EnvironmentObject var personalRecordsViewModel: PersonalRecordsViewModel
  @EnvironmentObject var profileViewModel: ProfileViewModel

  let gold = UIColor(red: 252.0/255.0, green: 194.0/255.0, blue: 0, alpha: 1.0)

  init(_ personalRecord: PersonalRecord) {
    self.personalRecord = personalRecord
  }

  func isFav(_ pr: PersonalRecord) -> Bool {
    return profileViewModel.isFav(pr)
  }

  func isMax(_ pr: PersonalRecord) -> Bool {
    return personalRecordsViewModel.isCategoryMax(pr: pr)
  }

  func setFav(_ pr: PersonalRecord) {
    profileViewModel.setFav(pr)
  }

  var prText: String {
    if personalRecord.category == "Calesthenics" {
      return "\(personalRecord.reps ?? 0)"
    } else if personalRecord.reps == 1 {
      return "\(personalRecord.weight ?? 0)"
    } else {
      return "\(personalRecord.weight ?? 0)x\(personalRecord.reps ?? 0)"
    }
  }

  var body: some View {
    HStack {
      Button {
        showingEditPersonalRecordView.toggle()
      } label: {
        // Date beautified (ex: Today)
        Text(relativeDay(personalRecord.timestamp.dateValue()))
          .frame(width: (UIScreen.main.bounds.width/3.5) - 15, height: 32)
          .background(Color(isFav(personalRecord) ? .systemBlue : .systemGray2))
          .cornerRadius(6)
//          .fontWeight(personalRecord.isCategoryMax ? .bold : .light)  //TODO: implement is Category Max logic
          .fontWeight(isFav(personalRecord) || isMax(personalRecord) ? .bold : .light)
          .foregroundColor(.white)

        // PR Type (ex: Bench)
        Text(" \(personalRecord.type)   ")
          .frame(width: (UIScreen.main.bounds.width/3) - 15, height: 32)
          .background(Color(isFav(personalRecord) ? .systemBlue : .systemGray2))
          .cornerRadius(6)
          .fontWeight(isFav(personalRecord) || isMax(personalRecord) ? .bold : .light)
          .foregroundColor(.white)

        // PR number (ex: 245)
        Text(" \(prText)   ")
          .frame(width: (UIScreen.main.bounds.width/3.5) - 15, height: 32)
          .background(Color(isFav(personalRecord) ? .systemBlue : .systemGray2))
          .cornerRadius(6)
//          .fontWeight(personalRecord.isCategoryMax ? .bold : .light)  //TODO: implement is Category Max logic
          .fontWeight(isFav(personalRecord) || isMax(personalRecord) ? .bold : .light)
          .foregroundColor(.white)
      }

      // Fav button
      Button {
        setFav(personalRecord)
      } label: {
        Image(systemName: "trophy.fill")
          .resizable()
          .frame(width: (UIScreen.main.bounds.width/11) - 15, height: 21)
          .scaledToFill()
          .background(.clear)
          .fontWeight(.semibold)
          .foregroundColor(isFav(personalRecord) ? Color(gold) : Color(.white))
      }
      .frame(width: (UIScreen.main.bounds.width/8) - 15, height: 32)
      .background(isFav(personalRecord) ? Color(.systemBlue) : Color(.systemGray2))
      .cornerRadius(6)
    }
    .font(.system(size: 12, weight: .regular, design: .rounded))
    .sheet(isPresented: $showingEditPersonalRecordView) {
      EditPersonalRecordView(personalRecord, shouldFlex: false)
    }
  }
}

#Preview {
  PersonalRecordCell(PersonalRecord.MOCK_PERSONAL_RECORDS[0])
}
