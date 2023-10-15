//
//  TrainingSessionCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct TrainingSessionCell: View {
  var body: some View {
    HStack() {
      
      VStack {
        // user profile image
        Image("uly")
          .resizable()
          .scaledToFill()
          .frame(width: 50, height: 50)
          .clipShape(Circle())
        // username
        Text("master_ulysses")
          .font(.footnote)
          .fontWeight(.semibold)
      }
      
      Spacer()
      VStack(alignment: .leading) {
        // body parts / workout type
        Text("  Chest ")
          .background(.green)
        Text("  Back   ")
          .background(.red)
        Text("  Abs     ")
          .background(.blue)
          
      }
      .foregroundColor(.white)
      .fontWeight(.bold)
      .cornerRadius(3)
      
      Spacer()
      
      VStack {
        // TrainingSession time
        Text("3pm")
          .font(.footnote)
          .fontWeight(.semibold)
        // TrainingSession location / gym
        Text("Redwood City 24")
          .font(.footnote)
          .fontWeight(.thin)
      }
    }
    .padding(.horizontal, 21)
  }
}

#Preview {
  TrainingSessionCell()
}
