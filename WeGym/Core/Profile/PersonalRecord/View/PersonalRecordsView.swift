//
//  PersonalRecordsView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI

struct PersonalRecordsView: View { //TODO: personal record blue color should be lighter as the PR is older / less weight/reps


  @State private var showingAddPersonalRecordView = false
  @StateObject private var viewModel = PersonalRecordsViewModel()

  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        ForEach(viewModel.personalRecords, id: \.self) { pr in
          PersonalRecordCell(pr)
        }
        Spacer()
      }
      .sheet(isPresented: $showingAddPersonalRecordView) {
        EditPersonalRecordView()
      }
      .environmentObject(viewModel)
      .padding(.top, 21)
      .navigationTitle("PRs")
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showingAddPersonalRecordView.toggle()
          } label: {
            Image(systemName: "plus")
              .foregroundColor(Color(.systemBlue))
              .padding(.horizontal, 9)
          }
        }
      }

    }
    .onDisappear {
      viewModel.removePersonalRecordListener()
    }
  }
}

#Preview {
  PersonalRecordsView()
}
