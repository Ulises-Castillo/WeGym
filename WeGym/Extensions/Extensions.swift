//
//  Extensions.swift
//  WeGym
//
//  Created by Ulises Castillo on 10/19/23.
//

import SwiftUI
import Firebase

extension UINavigationController {
  // Remove back button text
  open override func viewWillLayoutSubviews() {
    navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}

extension Timestamp {
  func timestampString() -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
    formatter.maximumUnitCount = 1
    formatter.unitsStyle = .abbreviated
    return formatter.string(from: self.dateValue(), to: Date()) ?? ""
  }
}

extension Date {
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }

  var noon: Date {
    return NSCalendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self) ?? self
  }

  var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)!
  }

  func advancedToNextHour() -> Date? {
    var date = self
    date += TimeInterval(59*60+59)
    let calendar = Calendar.current
    let components = calendar.dateComponents([.second, .minute], from: date)
    guard let minutes = components.minute,
          let seconds = components.second else {
      return nil
    }
    return date - TimeInterval(minutes)*60 - TimeInterval(seconds)
  }


  func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: self).capitalized
    // or use capitalized(with: locale) if you want
  }
}

extension View { //TODO: test
  @ViewBuilder
  func decreaseBadgeProminence() -> some View {
    if #available(iOS 17, *) {
      self
        .badgeProminence(.decreased)
    } else {
      self
    }
  }
}

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

extension Color {
  static var theme = Theme()
}

struct Theme {
  let primaryText = Color("PrimaryTextColor")
  let background = Color("BackgroundColor")
  let secondaryBackground = Color("SecondaryBackground")
}

extension String {
  static private var jsDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss 'GMT'Z"
    return formatter
  }()

  func parsedDate() -> Date? {
    let input = self.replacingOccurrences(of: #"\(.*\)$"#, with: "", options: .regularExpression)
    return String.jsDateFormatter.date(from: input)
  }

}

extension UIColor { //TODO: use these for lighter focus cells in the past, darker focus cells in the future

  func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
    return self.adjust(by: abs(percentage) )
  }

  func darker(by percentage: CGFloat = 30.0) -> UIColor? {
    return self.adjust(by: -1 * abs(percentage) )
  }

  func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: min(red + percentage/100, 1.0),
                     green: min(green + percentage/100, 1.0),
                     blue: min(blue + percentage/100, 1.0),
                     alpha: alpha)
    } else {
      return nil
    }
  }
}

