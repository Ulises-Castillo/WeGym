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
  
  var body: some View {
    
    NavigationStack {
      Divider()
      ScrollView {
        ForEach(TrainingSession.MOCK_TRAINING_SESSIONS) { session in
          Button {
            if let user = session.user, user.isCurrentUser {
              showingEditSheet.toggle()
            }
          } label: {
            TrainingSessionCell(trainingSession: session)
              .padding(.vertical, 12)
          }
          .sheet(isPresented: $showingEditSheet) {
            TrainingSessionSchedulerView()
          }
        }
      }
      .foregroundColor(.black)
      .navigationTitle("Today")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("navigate to tomorrow's view")
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
              .onChange(of: selectedDate) { _ in showingDateSheet.toggle() }
              .datePickerStyle(.graphical)
              .presentationDetents([.medium])
              .presentationDragIndicator(.hidden)
          }
        }
      }
    }
  }
}

#Preview {
  TrainingSessionView()
}

