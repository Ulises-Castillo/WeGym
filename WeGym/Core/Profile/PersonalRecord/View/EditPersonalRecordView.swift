//
//  EditPersonalRecordView.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/3/23.
//

import SwiftUI
import Combine
import Firebase
import SlideButton

struct EditPersonalRecordView: View {

  @EnvironmentObject var personalRecordsViewModel: PersonalRecordsViewModel
  @StateObject var viewModel = EditPersonalRecordViewModel()
  @State private var personalRecordNumber = ""
  @State private var notes = ""
  @State private var isKgs = false
  @FocusState private var isPrInputFocused: Bool
  @Environment(\.dismiss) var dismiss
  @State private var selectedNumberOfReps = 1
  @State private var shouldFlex = true
  var personalRecord: PersonalRecord?

  var selectedPersonalRecordCategory: String {
    return viewModel.selectedPersonalRecordCategory.first ?? ""
  }

  var isCalethenics: Bool {
    return selectedPersonalRecordCategory == "Calesthenics"
  }

  init(_ personalRecord: PersonalRecord? = nil) {
    self.personalRecord = personalRecord
  }

  func isPrValid() -> Bool {
    if !isCalethenics {
      return !viewModel.selectedPersonalRecordCategory.isEmpty &&
      !viewModel.selectedPersonalRecordType.isEmpty &&
      !personalRecordNumber.isEmpty
    } else {
      return !viewModel.selectedPersonalRecordCategory.isEmpty && //TODO: check for calesthenics
      !viewModel.selectedPersonalRecordType.isEmpty
    }
  }

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
          .padding(.bottom, 18)

          HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
              Toggle(isOn: $shouldFlex) { //TODO: add info tooltip to explain feature to user
                Text("Flex")
                  .font(.callout)
                  .frame(maxWidth: .infinity, alignment: .trailing)
              }
              .controlSize(.mini)
              .tint(Color(.systemBlue))
              .alignmentGuide(.lastTextBaseline) { context in
                context.height * 3.3
              }
              Spacer()
            }
            Spacer(minLength: UIScreen.main.bounds.width / (isCalethenics ? 3.5 : 21))
            if !isCalethenics {
              TextField("PR", text: $personalRecordNumber)
                .frame(width: 81)
                .fontWeight(.heavy)
                .font(.system(size: 33, weight: Font.Weight.heavy, design: Font.Design.monospaced))
                .keyboardType(.numberPad)
                .focused($isPrInputFocused)
                .multilineTextAlignment(.trailing)
              //              .opacity((selectedPersonalRecordCategory) != "Calesthenics" ? 1.0 : 0)
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
              Button { // make tappability more apparent to user with styling
                isKgs.toggle()
              } label: {
                Text(isKgs ? "kgs" : "lbs")
                  .font(.system(size: 18, weight: Font.Weight.light, design: Font.Design.rounded))
              }
              .padding(1)
              .foregroundColor(.secondary)

              Text("X")
                .font(.system(size: 18, weight: Font.Weight.semibold, design: Font.Design.monospaced))
            }

            let reps = [Int](1...(isCalethenics ? 99 : 21)) //TODO: rep range should be 1 - 6 for PWR, 1-50 for BB

            Picker("Reps", selection: $selectedNumberOfReps) {
              ForEach(reps, id: \.self) { rep in
                Text("\(rep)")
                  .font(.system(size: isCalethenics ? 39 : 24, weight: Font.Weight.heavy, design: Font.Design.monospaced))
              }
            }
            .alignmentGuide(.lastTextBaseline) { context in
////              context[.bottom] - 100.0 * context.height
////              -(context.height * 10)
              context.height / 1.86 //TODO: integrate `context[.bottom]` if  alignment is off on other screen sizes
            }
            .frame(width: isCalethenics ? 75 : 66)
            .pickerStyle(.wheel)
            .padding(.horizontal, -3)

            Text("rep" + (selectedNumberOfReps > 1 ? "s" : ""))
              .font(.system(size: isCalethenics ? 24 : 18, weight: Font.Weight.light, design: Font.Design.rounded))
              .foregroundColor(.secondary)
              .padding(.leading, -3)
          }
          .padding(.top, -(UIScreen.main.bounds.height / 27))
          .padding(.bottom, UIScreen.main.bounds.height / 33)
          .padding(.horizontal, isCalethenics ? 27 : 12)

          TextField("", text: $notes, prompt: Text("Add Notes...").foregroundColor(.primary), axis: .vertical)
            .padding()
            .padding(.bottom, UIScreen.main.bounds.height / 9)
            .font(.system(size: 16, weight: Font.Weight.medium, design: Font.Design.rounded))
            .disableAutocorrection(true)

          let slideButtonStyling = SlideButtonStyling(
            indicatorSize: 60,
            indicatorSpacing: 5,
            indicatorColor: .red,
            backgroundColor: .red.opacity(0.3),
            textColor: .secondary,
            indicatorSystemName: "trash",
            indicatorDisabledSystemName: "xmark",
            textAlignment: .globalCenter,
            textFadesOpacity: true,
            textHiddenBehindIndicator: true,
            textShimmers: false
          )

          if let pr = personalRecord {
            SlideButton("Delete", styling: slideButtonStyling, action: {
              Task { try await personalRecordsViewModel.deletePersonalRecord(pr) }
              dismiss()
            })
            .padding()
          }
        }
      }
      .scrollDismissesKeyboard(.interactively)
      .keyboardAvoiding()
      .navigationTitle((personalRecord == nil ? "Add" : "Edit") + " PR")
      .navigationBarTitleDisplayMode(.inline)
      .environmentObject(viewModel)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            guard isPrValid() else { return }

            Task {
              if let pr = personalRecord {

                let updatedPr = PersonalRecord(id: pr.id,
                                               weight: isCalethenics ? nil : Int(personalRecordNumber),
                                               reps: selectedNumberOfReps,
                                               category: viewModel.selectedPersonalRecordCategory.first ?? "",
                                               type: viewModel.selectedPersonalRecordType.first ?? "",
                                               ownerUid: UserService.shared.currentUser?.id ?? "",
                                               timestamp: pr.timestamp,
                                               notes: notes)

                try await personalRecordsViewModel.updatePersonalRecord(updatedPr)

              } else {
                let newPr = PersonalRecord(id: "",
                                           weight: isCalethenics ? nil : Int(personalRecordNumber),
                                           reps: selectedNumberOfReps,
                                           category: viewModel.selectedPersonalRecordCategory.first ?? "",
                                           type: viewModel.selectedPersonalRecordType.first ?? "",
                                           ownerUid: UserService.shared.currentUser?.id ?? "",
                                           timestamp: Timestamp(),
                                           notes: notes)

                try await personalRecordsViewModel.addPersonalRecord(newPr)
              }
            }
            dismiss()
          } label: {
            Image(systemName: "checkmark.square.fill")
          }
          .foregroundColor(isPrValid() ? .green : .gray)
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
        if let pr = personalRecord {
          personalRecordNumber = String(pr.weight ?? 0)
          notes = pr.notes
          viewModel.selectedPersonalRecordCategory = [pr.category]
          viewModel.selectedPersonalRecordType = [pr.type]
          selectedNumberOfReps = pr.reps ?? 1
        } else {
          isPrInputFocused = true
        }
      }
      .onTapGesture {
        self.endTextEditing()
      }
    }
  }
}

#Preview {
  EditPersonalRecordView(PersonalRecord.MOCK_PERSONAL_RECORDS[0])
}
