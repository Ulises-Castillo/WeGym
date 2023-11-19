//
//  LinkPreview.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/26/23.
//

import SwiftUI

struct LinkPreview: View {
  @StateObject var viewModel: LinkPreviewViewModel
  
  init(urlString: String) {
    self._viewModel = StateObject(wrappedValue: LinkPreviewViewModel(urlString: urlString))
  }
  
  var body: some View {
    if let metadata = viewModel.metadata {
      LPLinkViewRepresented(metadata: metadata)
        .frame(width: UIScreen.main.bounds.width * 0.66, height: UIScreen.main.bounds.height * 0.24)
    } else {
      ProgressView()
        .frame(width: UIScreen.main.bounds.width * 0.66, height: UIScreen.main.bounds.height * 0.24)
    }
  }
}

struct LinkPreview_Previews: PreviewProvider {
  static var previews: some View {
    LinkPreview(urlString: "https://www.youtube.com/watch?v=Qg0PepGlxFs")
  }
}
