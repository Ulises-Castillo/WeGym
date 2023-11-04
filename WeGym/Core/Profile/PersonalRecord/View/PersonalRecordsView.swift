//
//  PersonalRecordsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI

struct PersonalRecordsView: View { //TODO: personal record blue color should be lighter as the PR is older / less weight/reps


  @State private var showingEditPersonalRecordView = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        ForEach(0...1, id: \.self) { _ in
          PersonalRecordCell()
        }

        PersonalRecordCell(isFavorite: false, isMax: true)

        ForEach(0...3, id: \.self) { _ in
          PersonalRecordCell()
        }
        PersonalRecordCell(isFavorite: false, isMax: true)
        ForEach(0...6, id: \.self) { _ in
          PersonalRecordCell()
        }
        Spacer()
      }
      .sheet(isPresented: $showingEditPersonalRecordView) {
        EditPersonalRecordView()
      }
      .padding(.top, 21)
      .navigationTitle("PRs")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingEditPersonalRecordView.toggle()
          } label: {
            Image(systemName: "plus")
              .foregroundColor(Color(.systemBlue))
              .padding(.horizontal, 9)
          }
        }
      }

    }
  }
}

#Preview {
  PersonalRecordsView()
}
