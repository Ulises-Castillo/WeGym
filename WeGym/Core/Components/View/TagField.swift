import SwiftUI

/**
 TagField is an input textfield for SwiftUI that can contain tag data
 
 # Example #
 ```
 var tags:[String] = []
 
 TagField(tags: $tags, placeholder: "Add Tags..", prefix: "#")
 ```
 */
public struct TagField: View {
  @Binding public var tags: [String]
  @State private var newTag: String = ""
  @State var color: Color = Color(.sRGB, red: 50/255, green: 200/255, blue: 165/255)
  private var placeholder: String = ""
  private var prefix: String = ""
  private var style: TagFieldStyle = .RoundedBorder
  private var lowercase: Bool = false
  private var multiSelect: Bool
  private var isSelector: Bool
  private var isPersonalRecord: Bool

  @Binding var isSelected: [String]
  @EnvironmentObject var viewModel: TrainingSessionSchedulerViewModel
  @EnvironmentObject var prViewModel: EditPersonalRecordViewModel

  public var body: some View {
    VStack(spacing: 0){
      ScrollViewReader { scrollView in
        ScrollView(.horizontal, showsIndicators: false){
          HStack {
            
            ForEach(tags, id: \.self) { tag in
              Button {
                
                if let index = isSelected.firstIndex(of: tag), !isSelector {
                  isSelected.remove(at: index)
                } else if !multiSelect {
                  isSelected.removeAll()
                  isSelected.append(tag)
                } else {
                  isSelected.append(tag)
                }
                
                if isPersonalRecord {
                  if let selected = isSelected.first, isSelector {
                    prViewModel.personalRecordTypes = prViewModel.prCategoryMap[selected] ?? []
                  }
                  return
                }

                if let selected = isSelected.first, isSelector {
                  viewModel.workoutFocuses = SchedulerConstants.workoutCategoryFocusesMap[selected] ?? []
                }
              } label: {
                Text("\(prefix + tag)")
                  .fixedSize()
                  .foregroundColor((isSelected.contains(tag)) ? Color.white : color.opacity(0.8))
                  .font(.system(size: 15, weight: .medium, design: .rounded))
                  .padding([.horizontal], 10)
                  .padding(.vertical, 5)
                //                                Button(action :{
                //                                    withAnimation() {
                //                                        tags.removeAll { $0 == tag }
                //                                    }
                //                                }) {
                //                                    Image(systemName: "xmark")
                //                                        .foregroundColor(color.opacity(0.8))
                //                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                //                                        .padding([.trailing], 10)
                //                                }
              }.background((isSelected.contains(tag)) ? Color(.systemBlue).opacity(1).cornerRadius(isSelector ? 0 : .infinity) : color.opacity(0.1).cornerRadius(isSelector ? 0 : .infinity))
            }
            TextField(placeholder, text: $newTag, onEditingChanged: { _ in
              //              appendNewTag()
            }, onCommit: {
              appendNewTag()
            })
            .onChange(of: newTag) { change in
              //              if(change.isContainSpaceAndNewlines()) {
              //                appendNewTag()
              //              }
              withAnimation(Animation.easeOut(duration: 0).delay(1)) {
                scrollView.scrollTo("TextField", anchor: .trailing)
              }
              
            }
            .onAppear {
              if isPersonalRecord {
                if let initiallySelectedPRCategory = prViewModel.personalRecordCategories.first, isSelector {
                  isSelected.append(initiallySelectedPRCategory) //TODO: clean up logic
                  prViewModel.personalRecordTypes = prViewModel.prCategoryMap[initiallySelectedPRCategory] ??  []
                }

                return
              }

              if let initiallySelectedWorkoutCategory = viewModel.workoutCategories.first, isSelector {
                isSelected.append(initiallySelectedWorkoutCategory) //TODO: clean up logic
                viewModel.workoutFocuses = SchedulerConstants.workoutCategoryFocusesMap[initiallySelectedWorkoutCategory] ??  []
              }
            }
            .fixedSize()
            .disableAutocorrection(true)
            .autocapitalization(.words)
            .accentColor(color)
            .id("TextField")
            .padding(.trailing)
          }.padding()
        }
        .overlay(
          RoundedRectangle(cornerRadius: 5)
            .stroke(color, lineWidth: style == .RoundedBorder ? 0.75 : 0)
        )
      }.background(
        Color.gray.opacity(style == .Modern ? 0.07 : 0)
      )
      if(style == .Modern) {
        color.frame(height: 2).cornerRadius(1)
      }
      
    }
    
  }
  func appendNewTag() {
    var tag = newTag
    if(!isBlank(tag: tag)) {
      if(tag.last == " ") {
        tag.removeLast()
        if(!isOverlap(tag: tag)) {
          if(lowercase) {
            tag = tag.lowercased()
          }
          withAnimation() {
            tags.append(tag)
          }
        }
      }
      else {
        if(!isOverlap(tag: tag)) {
          if(lowercase) {
            tag = tag.lowercased()
          }
          withAnimation() {
            tags.append(tag)
          }
        }
      }
    }
    newTag.removeAll()
  }
  func isOverlap(tag: String) -> Bool {
    if(tags.contains(tag)) {
      return true
    }
    else {
      return false
    }
  }
  func isBlank(tag: String) -> Bool {
    let tmp = tag.trimmingCharacters(in: .whitespaces)
    if(tmp == "") {
      return true
    }
    else {
      return false
    }
  }
  public init(tags: Binding<[String]>, 
              set: Binding<[String]>,
              placeholder: String,
              multiSelect: Bool,
              isSelector: Bool,
              isPersonalRecord: Bool) {
    self._tags = tags
    self._isSelected = set
    self.placeholder = placeholder
    self.multiSelect = multiSelect
    self.isSelector = isSelector
    self.isPersonalRecord = isPersonalRecord
  }
  
  public init(tags: Binding<[String]>, 
              set: Binding<[String]>,
              placeholder: String,
              prefix: String,
              multiSelect: Bool,
              isSelector: Bool,
              isPersonalRecord: Bool) {
    self._tags = tags
    self._isSelected = set
    self.placeholder = placeholder
    self.prefix = prefix
    self.multiSelect = multiSelect
    self.isSelector = isSelector
    self.isPersonalRecord = isPersonalRecord
  }
  
  public init(tags: Binding<[String]>, 
              set: Binding<[String]>,
              placeholder: String,
              prefix: String,
              color: Color,
              style: TagFieldStyle,
              lowercase: Bool,
              multiSelect: Bool,
              isSelector: Bool,
              isPersonalRecord: Bool) {
    self._tags = tags
    self._isSelected = set
    self.prefix = prefix
    self.placeholder = placeholder
    self._color = .init(initialValue: color)
    self.style = style
    self.lowercase = lowercase
    self.multiSelect = multiSelect
    self.isSelector = isSelector
    self.isPersonalRecord = isPersonalRecord
  }
}

extension TagField {
  public func accentColor(_ color: Color) -> TagField {
    TagField(tags: self.$tags,
             set: self.$isSelected,
             placeholder: self.placeholder, prefix: self.prefix,
             color: color,
             style: self.style,
             lowercase: self.lowercase,
             multiSelect: self.multiSelect,
             isSelector: self.isSelector,
             isPersonalRecord: self.isPersonalRecord)
  }
  public func styled(_ style: TagFieldStyle) -> TagField {
    TagField(tags: self.$tags,
             set: self.$isSelected,
             placeholder: self.placeholder, prefix: self.prefix,
             color: self.color,
             style: style,
             lowercase: self.lowercase,
             multiSelect: self.multiSelect,
             isSelector: self.isSelector,
             isPersonalRecord: self.isPersonalRecord)
  }
  public func lowercase(_ bool: Bool) -> TagField {
    TagField(tags: self.$tags,
             set: self.$isSelected,
             placeholder: self.placeholder,
             prefix: self.prefix,
             color: self.color,
             style: self.style,
             lowercase: bool,
             multiSelect: self.multiSelect,
             isSelector: self.isSelector,
             isPersonalRecord: self.isPersonalRecord)
  }
}
