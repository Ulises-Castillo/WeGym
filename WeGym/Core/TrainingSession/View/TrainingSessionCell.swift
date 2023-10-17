//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {
  let trainingSession: TrainingSession
  
  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      
      HStack {
        // user profile image
        Image(trainingSession.user!.profileImageUrl!) //FIXME: unwrap
          .resizable()
          .scaledToFill()
          .frame(width: 33, height: 33)
          .clipShape(Circle())
        // username
        Text(trainingSession.user!.fullName!) //FIXME: unwrap
          .font(.subheadline)
          .fontWeight(.semibold)
        
         + Text(" ") + Text(trainingSession.caption ?? "")
          .fontWeight(.regular)
          .font(.subheadline)
          
        
        Spacer()
      }
      .frame(maxWidth: .infinity, alignment: .leading) // may not need this
      .multilineTextAlignment(.leading)

      

      HStack {
        // body parts / workout type
        ForEach(trainingSession.focus, id: \.self) { focus in
          Text("  \(focus)  ")
            .background(Color(.systemBlue))
            .cornerRadius(6)
        }
        
//        Text(" Chest    ")
//          .background(.green)
//          .cornerRadius(6)
//        Text("   Back     ")
//          .background(.red)
//          .cornerRadius(6)
//        Text("    Abs      ")
//          .background(.blue)
//          .cornerRadius(6)
//          
      }
      .foregroundColor(.white)
      .fontWeight(.bold)
      .font(.title)
      
      HStack {
        // TrainingSession time
//        Text(trainingSession.date.formatted(.time(pattern: .hourMinute)))
        Text(trainingSession.date.dateValue(), format: .dateTime.hour().minute())
          .fontWeight(.semibold)
        // TrainingSession location / gym
        if let location = trainingSession.location {
          Text(location)
            .fontWeight(.thin)
        }
      }
      .font(.subheadline)
    }
    .padding(.leading, 21)
  }
}

#Preview {
  TrainingSessionCell(trainingSession: TrainingSession.MOCK_TRAINING_SESSIONS[0])
}
