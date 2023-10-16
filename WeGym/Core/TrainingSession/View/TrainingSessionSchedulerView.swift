//
//  TrainingSessionSchedulerView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/15/23.
//

import SwiftUI
import Combine

struct TrainingSessionSchedulerView: View {
  @State var workoutTime = Date()
  @State var workoutCaption = ""
  @State var workoutIsRecurring = false
  @State var workoutBroLimit = ""
  @State var gyms: [String] = ["Redwood City 24", "San Carlos 24", "Mountain View 24", "Vallejo In-Shape"]
  @State var workoutTypes: [String] = ["Chest", "Back", "Arms", "Legs", "Shoulders", "Abs", "Biceps", "Triceps", "Calves", "Upper Body", "Lower Body", "Full Body"]
  
  @State private var showingSearchSheet = false
  
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    NavigationStack { //FIXME: remove nested navigation stack
      Divider()
      ScrollView {
        // select workout / body parts
        TagField(tags: $workoutTypes, placeholder: "Other", prefix: "", multiSelect: true)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .lowercase(true)
          .padding()
        
        // set workout time
        //TODO: start date range should round up to the next 30min / hour
        DatePicker("Set workout time:", selection: $workoutTime, in: Date()..., displayedComponents: .hourAndMinute)
          .padding()
          .font(.title3)
          .fontWeight(.medium)
        
        // set gym / workout location
        TagField(tags: $gyms, placeholder: "Other", prefix: "", multiSelect: false)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .lowercase(true)
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
        }
        .padding()
        .font(.title3)
        
        // Invite gym bros, if bro limit greater than 0
        // (if more bros invited than limit, adjust limit auto)
        Button {
          showingSearchSheet.toggle()
        } label: {
          HStack {
            Text("Invite Gym Rats")
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
      
      .navigationTitle("Edit Workout")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
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
    }
    .onTapGesture {
      
      self.endTextEditing()
    }
  }
}

#Preview {
  TrainingSessionSchedulerView()
}


//TODO: move to appropirate place for extensions, constant, etc.
extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}
