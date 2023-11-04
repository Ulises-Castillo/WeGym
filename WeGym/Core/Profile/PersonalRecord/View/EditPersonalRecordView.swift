//
//  EditPersonalRecordView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI
import Combine

struct EditPersonalRecordView: View {

  @StateObject var viewModel = EditPersonalRecordViewModel()
  @State private var personalRecordNumber = ""
  @State private var notes = ""
  @State private var isKgs = false
  @FocusState private var isPrFocused: Bool
  @Environment(\.dismiss) var dismiss

  var body: some View {
    NavigationStack {
      Divider()
      ScrollView {
        VStack {
          TagField(tags: $viewModel.personalRecordCategories,
                   set: $viewModel.selectedPersonalRecordCategory,
                   placeholder: "", prefix: "",
                   multiSelect: false,
                   isSelector: true,
                   isPersonalRecord: true)
          .accentColor(Color(.systemBlue))

          TagField(tags: $viewModel.personalRecordTypes,
                   set: $viewModel.selectedPersonalRecordType,
                   placeholder: "Other",
                   prefix: "",
                   multiSelect: false,
                   isSelector: false,
                   isPersonalRecord: true)
          .styled(.Modern)
          .accentColor(Color(.systemBlue))
          .padding()

          HStack {
            Spacer()
            TextField("PR", text: $personalRecordNumber)
              .frame(width: 66)
              .fontWeight(.heavy)
              .font(.system(size: 33, weight: Font.Weight.heavy, design: Font.Design.rounded))
              .keyboardType(.numberPad)
              .focused($isPrFocused)
              .multilineTextAlignment(.trailing)
              .onReceive(Just(personalRecordNumber)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                  self.personalRecordNumber = filtered
                }
              }
              .onReceive(Just(personalRecordNumber)) { _ in
                      if personalRecordNumber.count > 3 {
                        personalRecordNumber = String(personalRecordNumber.prefix(3))
                      }
                  }
            Button {
              isKgs.toggle()
            } label: {
              Text(isKgs ? "kgs" : "lbs")
                .font(.system(size: 18, weight: Font.Weight.light, design: Font.Design.rounded))
            }
            .padding(1)
            .foregroundColor(.secondary)
          }
          .padding(.vertical, 24)
          .padding(.horizontal, 24)

          TextField("", text: $notes, prompt: Text("Add Notes...").foregroundColor(.primary), axis: .vertical)
            .padding()
            .padding(.bottom, 90)
            .font(.system(size: 16, weight: Font.Weight.medium, design: Font.Design.rounded))
            .disableAutocorrection(true)

          //TODO: add delete slider for "edit PR"
        }
      }
      .navigationTitle("Add PR") //TODO: will be add or edit depending on whether a PR is passed in or not
      .navigationBarTitleDisplayMode(.inline)
      .environmentObject(viewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "checkmark.square.fill")
          }
          .foregroundColor(.green)
//          .foregroundColor(schedulerViewModel.selectedWorkoutFocuses.isEmpty ? .gray : .green)
        }
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "x.square.fill")
          }
          .foregroundColor(.red)
        }
      }
      .onAppear {
        isPrFocused = true //TODO: only focus if adding PR, not for "edit PR"
      }
    }
  }
}

#Preview {
  EditPersonalRecordView()
}
