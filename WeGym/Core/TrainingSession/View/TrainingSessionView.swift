//
//  TrainingSessionView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionView: View {
  
  @State private var selectedDate: Date = .now
  @State private var showingDateSheet = false
  @State private var showingEditSheet = false
  
  @StateObject var viewModel = TrainingSessionViewModel()
  
  let user: User
  
  var body: some View {
    
    NavigationStack {
      Divider()
      ScrollView {
        
        Button {
          if viewModel.day.timeIntervalSince1970 > Date.now.startOfDay.timeIntervalSince1970 {
            showingEditSheet.toggle()
          }
        } label: {
          if let session = viewModel.currentUserTrainingSesssion {
            TrainingSessionCell(trainingSession: session)
          } else if !viewModel.isFirstFetch && !viewModel.isFetching {
            RestDayCell(user: user)
          }
        }
        .padding(.vertical, 12)
        .sheet(isPresented: $showingEditSheet) {
          TrainingSessionSchedulerView(user: user)
        }
        ForEach(viewModel.trainingSessions) { session in
          Button {
            print("Join bro's session")
          } label: {
            TrainingSessionCell(trainingSession: session)
              .padding(.vertical, 12)
          }
        }
      }
      .foregroundColor(.black)
      .navigationTitle(viewModel.relaiveDay())
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            viewModel.day = viewModel.day.addingTimeInterval(86400)
            selectedDate = selectedDate.addingTimeInterval(86400)
            Task{ try await viewModel.fetchTrainingSessions() }
          } label: {
            Image(systemName: "arrowtriangle.forward")
              .foregroundColor(.black)
              .padding(.horizontal, 9)
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            showingDateSheet.toggle()
          } label: {
            Image(systemName: "calendar")
              .foregroundColor(.black)
          }
          .sheet(isPresented: $showingDateSheet) {
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
              .onChange(of: selectedDate) { _ in
                showingDateSheet.toggle()
                viewModel.day = selectedDate
                Task{ try await viewModel.fetchTrainingSessions() }
              }
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .presentationDragIndicator(.hidden)
          }
        }
      }
    }
    .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
      .onEnded { value in
        print(value.translation)
        switch(value.translation.width, value.translation.height) {
        case (...0, -30...30):
          viewModel.day = viewModel.day.addingTimeInterval(86400)
          selectedDate = selectedDate.addingTimeInterval(86400)
          Task{ try await viewModel.fetchTrainingSessions() }
        case (0..., -30...30):
          viewModel.day = viewModel.day.addingTimeInterval(-86400)
          selectedDate = selectedDate.addingTimeInterval(-86400)
          Task{ try await viewModel.fetchTrainingSessions() }
        default:
          break
        }
      }
    )
    .onAppear{
      selectedDate = Date()
      viewModel.day = selectedDate
      Task{ try await viewModel.fetchTrainingSessions() }
    }
    .environmentObject(viewModel)
  }
}

#Preview {
  TrainingSessionView(user: User.MOCK_USERS[0])
}

