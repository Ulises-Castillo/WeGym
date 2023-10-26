//
//  ActiveNowView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

import SwiftUI

struct ActiveNowView: View {
    @StateObject var viewModel = ActiveNowViewModel()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(viewModel.users) { user in
//                    NavigationLink(value: Route.chatView(user)) {
//                        VStack {
//                            ZStack(alignment: .bottomTrailing) {
//                                CircularProfileImageView(user: user, size: .medium)
//
//                                ZStack {
//                                    Circle()
//                                        .fill(Color.theme.background)
//                                        .frame(width: 16, height: 16)
//
//                                    Circle()
//                                        .fill(.green)
//                                        .frame(width: 10, height: 10)
//                                }
//                            }
//
//                            Text(user.firstName)
//                                .font(.footnote)
//                                .foregroundColor(.gray)
//                        }
//                    }
                }
            }
        }
    }
}

struct ActiveNowView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveNowView()
    }
}
