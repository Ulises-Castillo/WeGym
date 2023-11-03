//
//  TrainingSessionUtils.swift
//  WeGym
//
//  Created by Ulises Castillo on 11/2/23.
//

import Foundation

func beautifyWorkoutFocuses(focuses: [String]) -> [String] {
  var beautifiedFocuses = focuses
  // make set with BRO & PPL
  let categorySet = Set<String>(SchedulerConstants.workoutCategoryFocusesMap["BRO"]! +
                                SchedulerConstants.workoutCategoryFocusesMap["PPL"]!)
  var majorFocus: String?

  // loop through selected focuses
  for focus in beautifiedFocuses {
    if categorySet.contains(focus) {
      if majorFocus != nil {
        return beautifiedFocuses
      } else {
        majorFocus = focus
      }
    }
  }
  // if only one tag from BRO or PPL found
  if var majorFocus = majorFocus {
    // remove original focus
    if let index = beautifiedFocuses.firstIndex(of: majorFocus) {
      beautifiedFocuses.remove(at: index)
    }
    // make singular, if plural
    if majorFocus.last == "s" {
      majorFocus = String(majorFocus.dropLast(1))
    }
    // append "Day"
    majorFocus = majorFocus + " Day"
    beautifiedFocuses.insert(majorFocus, at: 0)
  }
  return beautifiedFocuses
}

func relaiveDay(_ date: Date) -> String {
  let relativeDateFormatter = DateFormatter()
  relativeDateFormatter.timeStyle = .none
  relativeDateFormatter.dateStyle = .medium
  relativeDateFormatter.locale = Locale(identifier: "en_US")
  relativeDateFormatter.doesRelativeDateFormatting = true

  guard let dayOfWeek = date.dayOfWeek(),
        let diff = Calendar.current.dateComponents([.day], from: date, to: Date()).day else { return "" }

  let relativeDate = relativeDateFormatter.string(from: date)
  let daySet: Set<String> = ["Yesterday", "Today", "Tomorrow"]

  if daySet.contains(relativeDate)  {
    return relativeDate
  } else if diff <= 6 && diff >= -6 {
    let calendar = Calendar.current
    if dayOfWeek == "Sunday" && diff > 0 {
      return "Past Sunday"
    } else if calendar.component(.weekOfYear, from: date) == calendar.component(.weekOfYear, from: Date()) {
      return dayOfWeek
    } else if diff > 0 {
      return "Past " + dayOfWeek
    } else if diff >= -6 && dayOfWeek == "Sunday" {
      return dayOfWeek
    } else {
      return "Next " + dayOfWeek
    }
  } else {
    return dayOfWeek + ", " + relativeDate.dropLast(6)
  }
}

