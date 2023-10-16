//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 9) {
      
      HStack {
        // user profile image
        Image("uly")
          .resizable()
          .scaledToFill()
          .frame(width: 33, height: 33)
          .clipShape(Circle())
        // username
        Text("Ulysses ")
          .font(.subheadline)
          .fontWeight(.semibold)
        
        + Text("Going for a bench PR today ! 💪")
          .fontWeight(.regular)
          .font(.subheadline)
        
        Spacer()
      }
      

      HStack {
        // body parts / workout type
        Text(" Chest    ")
          .background(.green)
          .cornerRadius(6)
        Text("   Back     ")
          .background(.red)
          .cornerRadius(6)
        Text("    Abs      ")
          .background(.blue)
          .cornerRadius(6)
          
      }
      .foregroundColor(.white)
      .fontWeight(.bold)
      .font(.title)
      
      HStack {
        // TrainingSession time
        Text("3pm")
          .fontWeight(.semibold)
        // TrainingSession location / gym
        Text("Redwood City 24")
          .fontWeight(.thin)
      }
      .font(.subheadline)
    }
    .padding(.leading, 21)
  }
}

#Preview {
  TrainingSessionCell()
}
