//
//  ProfileView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/12/23.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    @StateObject var viewModel: ProfileViewModel

    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProfileHeaderView(viewModel: viewModel)

                PostGridView(config: .profile(user))
            }
            .padding(.top)
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}
