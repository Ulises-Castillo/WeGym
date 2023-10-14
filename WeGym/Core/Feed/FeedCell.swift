//
//  FeedCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI

struct FeedCell: View {
    var body: some View {
      VStack {
        
        // image + username
        HStack {
          Image("uly")
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
          
          Text("master_ulysses")
            .font(.footnote)
            .fontWeight(.semibold)
          
          Spacer()
        }
        .padding(.leading, 8)
        
        // post image
        Image("smoke")
          .resizable()
          .scaledToFill()
          .frame(height: 400)
          .clipShape(Rectangle())
        
        
        // action buttons
        HStack(spacing: 16) {
          Button {
            print("Like post")
          } label: {
            Image(systemName: "heart")
              .imageScale(.large)
          }
          
          Button {
            print("Comment on post")
          } label: {
            Image(systemName: "bubble.right")
              .imageScale(.large)
          }
          
          Button {
            print("Share post")
          } label: {
            Image(systemName: "paperplane")
              .imageScale(.large)
          }
          Spacer()
        }
        .padding(.leading, 8)
        .padding(.top, 4)
        .foregroundColor(.black)
        
        // likes label
        Text("23 likes")
          .font(.footnote)
          .fontWeight(.semibold)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
          .padding(.top, 1)
        
        // caption label
        HStack {
          Text("Ulysses A. Castillo ").fontWeight(.semibold) +
          Text("Amat Victoria Curam 💪")
        }
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
        .padding(.top, 1)
        
        Text("6h ago")
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.leading, 10)
          .padding(.top, 1)
          .foregroundColor(.gray)
      }
    }
}

#Preview {
    FeedCell()
}
