//
//  TrainingSessionSchedulerView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/15/23.
//

import SwiftUI
import Combine
import TagField //TODO: modify to have support multiline

struct TrainingSessionSchedulerView: View {
  @State var workoutTime = Date()
  @State var workoutCaption = ""
  @State var workoutIsRecurring = false
  @State var workoutBroLimit = ""
  @State var gyms: [String] = ["Redwood City 24", "San Carlos 24", "Mountain View 24", "Vallejo In-Shape"]
  @State var workoutTypes: [String] = ["Chest", "Back", "Arms", "Legs", "Shoulders", "Abs", "Biceps", "Triceps", "Calves", "Upper Body", "Lower Body", "Full Body"]
  
  var body: some View {
    NavigationStack { //FIXME: remove nested navigation stack
      Divider()
      ScrollView {
        // select workout / body parts
        TagField(tags: $workoutTypes, placeholder: "Other", prefix: "")
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .lowercase(true)
          .padding()
        
        // set workout time
        DatePicker("Set workout time:", selection: $workoutTime, in: Date()..., displayedComponents: .hourAndMinute)
          .padding()
          .font(.title3)
          .fontWeight(.medium)
        
        // set gym / workout location
        // select workout / body parts
        TagField(tags: $gyms, placeholder: "Other", prefix: "")
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .lowercase(true)
          .padding()
        
        // set workout comment / theme (perhaps image in the future)
        TextField("Caption:", text: $workoutCaption)
          .padding()
          .font(.title3)
        
        HStack{
          // set reoccuring + set bro limit
          TextField("Bro Limit", text: $workoutBroLimit)
          //            .padding()
            .keyboardType(.numberPad)
            .onReceive(Just(workoutBroLimit)) { newValue in
              let filtered = newValue.filter { "0123456789".contains($0) }
              if filtered != newValue {
                self.workoutBroLimit = filtered
              }
            }
          
          Spacer()
          
          Toggle("Weekly:", isOn: $workoutIsRecurring)
            .padding()
            .font(.title3)
            .fontWeight(.medium)
        }
        .padding()
        .font(.title3)
        
        // Invite gym bros, if bro limit greater than 0
        // (if more bros invited than limit, adjust limit auto)
        Button {
          print("navigate to search view to invite gym bros to workout")
          // SearchView() //
        } label: {
          Text("Invite Gym Bros")
          Image(systemName: "plus")
        }
        .font(.headline)
        .fontWeight(.semibold)
        .frame(width: 360, height: 32)
        .background(Color(.systemBlue))
        .foregroundColor(.white)
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.clear, lineWidth: 1))
      }
      
      .navigationTitle("Today")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            print("navigate to tomorrow's view")
          } label: {
            Text("Done")
          }
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            print("navigate to tomorrow's view")
          } label: {
            Text("Cancel")
          }
        }
      }
    }
  }
}

#Preview {
  TrainingSessionSchedulerView()
}
