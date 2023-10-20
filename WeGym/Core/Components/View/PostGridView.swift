//
//  PostGridView.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/14/23.
//

import SwiftUI
import Kingfisher


struct PostGridView: View {
    private let items = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
    ]
    private let width = (UIScreen.main.bounds.width / 3) - 2

    let config: PostGridConfiguration
    @StateObject var viewModel: PostGridViewModel

    init(config: PostGridConfiguration) {
        self.config = config
        self._viewModel = StateObject(wrappedValue: PostGridViewModel(config: config))
    }

    var body: some View {
        LazyVGrid(columns: items, spacing: 2, content: {
            ForEach(viewModel.posts) { post in
                NavigationLink(value: post) {
                    KFImage(URL(string: post.imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: width)
                        .clipped()
                }
                .onAppear {
                    guard let index = viewModel.posts.firstIndex(where: { $0.id == post.id }) else { return }
                    if case .explore = config, index == viewModel.posts.count - 1 {
//                        viewModel.fetchExplorePagePosts() //TODO: add this
                    }
                }
            }
        })
        .navigationDestination(for: Post.self) { post in
            FeedCell(post: post)
        }
    }
}
