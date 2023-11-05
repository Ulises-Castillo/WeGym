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

  let gold = UIColor(red: 252.0/255.0, green: 194.0/255.0, blue: 0, alpha: 1.0)

  init(_ personalRecord: PersonalRecord) {
    self.personalRecord = personalRecord
  }

  var body: some View {
    HStack {
      Button {
        showingEditPersonalRecordView.toggle()
      } label: {
        // Date beautified (ex: Today)
        Text(relativeDay(personalRecord.timestamp.dateValue()))
          .frame(width: (UIScreen.main.bounds.width/3.5) - 15, height: 32)
          .background(Color(personalRecord.isFavorite ? .systemBlue : .systemGray2))
          .cornerRadius(6)
          .fontWeight(personalRecord.isCategoryMax ? .bold : .light)
          .foregroundColor(.white)

        // PR Type (ex: Bench)
        Text(" \(personalRecord.type)   ") //TODO: investigate actual root cause of issue
          .frame(width: (UIScreen.main.bounds.width/3) - 15, height: 32)
          .background(Color(personalRecord.isFavorite ? .systemBlue : .systemGray2))
          .cornerRadius(6)
          .fontWeight(personalRecord.isCategoryMax ? .bold : .light)
          .foregroundColor(.white)

        // PR number (ex: 245)
        Text(" \(personalRecord.weight ?? 0)   ") //TODO: investigate actual root cause of issue
          .frame(width: (UIScreen.main.bounds.width/3.5) - 15, height: 32)
          .background(Color(personalRecord.isFavorite ? .systemBlue : .systemGray2))
          .cornerRadius(6)
          .fontWeight(personalRecord.isCategoryMax ? .bold : .light)
          .foregroundColor(.white)
      }

      // Fav button
      Button {
        personalRecordsViewModel.setFavorite(personalRecord)
      } label: {
        Image(systemName: "star.square.fill")
          .resizable()
          .frame(width: (UIScreen.main.bounds.width/8) - 15, height: 32)
          .background(personalRecord.isFavorite ? Color(gold) : .clear)
          .cornerRadius(6)
          .fontWeight(.semibold)
          .foregroundColor(Color(.systemBlue))
      }
    }
    .font(.system(size: 14, weight: .regular, design: .rounded))
    .sheet(isPresented: $showingEditPersonalRecordView) {
      EditPersonalRecordView(personalRecord)
    }
  }
}

#Preview {
  PersonalRecordCell(PersonalRecord.MOCK_PERSONAL_RECORDS[0])
}
