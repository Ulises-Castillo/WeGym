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
