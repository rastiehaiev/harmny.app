//
//  DateUtils.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 05.01.2024.
//

import Foundation

class DateUtils {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func parse(_ dateString: String) -> Date? {
        return dateFormatter.date(from: dateString)
    }
    
    static func asString(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
