//
//  TrainingSessionSchedulerView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/15/23.
//

import SwiftUI
import Combine
import Firebase

struct TrainingSessionSchedulerView: View {
  @State var workoutTime = Date()
  @State var workoutCaption = ""
  @State var workoutIsRecurring = false
  @State var workoutBroLimit = ""
  @State var gyms: [String] = ["Redwood City 24", "San Carlos 24", "Mountain View 24", "Vallejo In-Shape"]
  @State var workoutTypes: [String] = ["Chest", "Back", "Arms", "Legs", "Shoulders", "Abs", "Biceps", "Triceps", "Calves", "Upper Body", "Lower Body", "Full Body"]
  
  @State var focus = Set<String>()
  @State var gym = Set<String>()
  
  @State private var showingSearchSheet = false
  
  @Environment(\.dismiss) var dismiss
  
  @EnvironmentObject var viewModel: TrainingSessionViewModel
  
  let user: User
  
  var body: some View {
    NavigationStack { //FIXME: remove nested navigation stack
      Divider()
      ScrollView {
        // select workout / body parts
        TagField(tags: $workoutTypes, set: $focus, placeholder: "Other", prefix: "", multiSelect: true)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .padding()
        
        // set workout time
        //TODO: start date range should round up to the next 30min / hour
        DatePicker("Set workout time:", selection: $workoutTime, in: Date()..., displayedComponents: .hourAndMinute)
          .padding()
          .font(.title3)
          .fontWeight(.medium)
        
        // set gym / workout location
        TagField(tags: $gyms, set: $gym, placeholder: "Other", prefix: "", multiSelect: false)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .padding()
        
        // set workout comment / theme (perhaps image in the future)
        TextField("Caption:", text: $workoutCaption, axis: .vertical)
          .padding()
          .font(.title3)
        
        
        HStack{
          // set reoccuring + set bro limit
          HStack {
            Text("Bro Limit:")
              .lineLimit(1)
              .minimumScaleFactor(0.01) //FIXME: all text should be same size on any given screen size
            
            TextField("None", text: $workoutBroLimit)
              .keyboardType(.numberPad)
              .onReceive(Just(workoutBroLimit)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                  self.workoutBroLimit = filtered
                }
              }
          }
          
          Spacer()
          
          Toggle("Weekly:", isOn: $workoutIsRecurring)
            .padding()
            .font(.title3)
            .fontWeight(.medium)
            .tint(Color(.systemBlue))
        }
        .padding()
        .font(.title3)
        
        // Invite gym bros, if bro limit greater than 0
        // (if more bros invited than limit, adjust limit auto)
        Button {
          showingSearchSheet.toggle()
        } label: {
          HStack {
            Text("Invite Gym Bros")
            Image(systemName: "plus")
          }
          .font(.headline)
          .fontWeight(.semibold)
          .frame(width: 360, height: 50)
          .background(Color(.systemBlue))
          .foregroundColor(.white)
          .cornerRadius(6)
          .overlay(RoundedRectangle(cornerRadius: 6).stroke(.clear, lineWidth: 1))
        }
        .sheet(isPresented: $showingSearchSheet) {
          SearchView()
        }
      }
      .foregroundColor(.primary)
      .navigationTitle(viewModel.currentUserTrainingSesssion == nil ? "Add Workout" : "Edit Workout")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            Task {
              
              
              if let prevSession = viewModel.currentUserTrainingSesssion {
                
                let newSession = TrainingSession(id: prevSession.id,
                                                 ownerUid: user.id,
                                                 date: Timestamp(date: workoutTime),
                                                 focus: [String](focus),
                                                 location: gym.first,
                                                 caption: workoutCaption,
                                                 user: user)
                
                try await TrainingSessionService.updateTrainingSession(trainingSession: newSession)
                
              } else {
                try await TrainingSessionService
                  .uploadTrainingSession(date: Timestamp(date: workoutTime),
                                         focus: [String](focus),
                                         location: gym.first,
                                         caption: workoutCaption)
                
                viewModel.currentUserTrainingSesssion = TrainingSession(id: "",
                                                                        ownerUid: "",
                                                                        date: Timestamp(date: workoutTime),
                                                                        focus: [String](focus),
                                                                        location: gym.first,
                                                                        caption: workoutCaption,
                                                                        user: user)
              }
              try await viewModel.fetchTrainingSessions()
            }
            dismiss()
          } label: {
            Image(systemName: "checkmark")
          }
          .foregroundColor(.green)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .foregroundColor(.red)
        }
      }
    }.onAppear {
      if let session = viewModel.currentUserTrainingSesssion {
        workoutTime = session.date.dateValue()
        workoutCaption = session.caption ?? ""
        focus = Set<String>(session.focus)
        guard let location = session.location else { return }
        gym.insert(location)
      } else {
        workoutTime = viewModel.day
      }
    }
    .onTapGesture {
      self.endTextEditing()
    }
  }
}

#Preview {
  TrainingSessionSchedulerView(user: User.MOCK_USERS[0])
}


//TODO: move to appropirate place for extensions, constant, etc.
extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}
