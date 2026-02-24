//
//  DateFormatter+Extensions.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/3/22.
//

import Foundation

extension Date {

    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated   // 2m, 3h, 1d
        formatter.dateTimeStyle = .numeric

        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
