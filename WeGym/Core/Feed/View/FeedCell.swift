//
//  FeedCell.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI
import Kingfisher

struct FeedCell: View {
  let post: Post
  
  var body: some View {
    VStack {
      
      // image + name
      HStack {
        if let user = post.user {
          CircularProfileImageView(user: user, size: .xSmall)
          
          Text(user.name)
            .font(.footnote)
            .fontWeight(.semibold)
        }
        
        Spacer()
      }
      .padding(.leading, 8)
      
      // post image
      KFImage(URL(string: post.imageUrl))
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
      Text("\(post.likes) likes")
        .font(.footnote)
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
        .padding(.top, 1)
      
      // caption label
      HStack {
        Text("\(post.user?.name ?? "") ").fontWeight(.semibold) +
        Text(post.caption)
      }
      .font(.footnote)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, 10)
      .padding(.top, 1)
      
      Text("6h ago") //FIXME: implement dynamic time
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 10)
        .padding(.top, 1)
        .foregroundColor(.gray)
    }
  }
}

#Preview {
  FeedCell(post: Post.MOCK_POSTS[0])
}
