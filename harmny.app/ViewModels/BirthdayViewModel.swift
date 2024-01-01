//
//  BirthdayViewModel.swift
//  harmny.app
//
//  Created by Roman Rastegaev on 30.12.2023.
//

import Combine
import Foundation

/// An observable class representing the current user's `Birthday` and the number of days until that date.
final class BirthdayViewModel: ObservableObject {
    /// The `Birthday` of the current user.
    /// - note: Changes to this property will be published to observers.
    @Published private(set) var birthday: Birthday?
    /// Computed property calculating the number of days until the current user's birthday.
    var daysUntilBirthday: String {
        guard let bday = birthday?.date else {
            return NSLocalizedString("No birthday", comment: "User has no birthday")
        }
        let now = Date()
        let calendar = Calendar.autoupdatingCurrent
        let dayComps = calendar.dateComponents([.day], from: now, to: bday)
        guard let days = dayComps.day else {
            return NSLocalizedString("No birthday", comment: "User has no birthday")
        }
        return String(days)
    }
    private var cancellable: AnyCancellable?
    private let birthdayLoader = BirthdayLoader()
    
    /// Fetches the birthday of the current user.
    func fetchBirthday() {
        birthdayLoader.birthdayPublisher { publisher in
            self.cancellable = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.birthday = Birthday.noBirthday
                    print("Error retrieving birthday: \(error)")
                }
            } receiveValue: { birthday in
                self.birthday = birthday
            }
        }
    }
}
