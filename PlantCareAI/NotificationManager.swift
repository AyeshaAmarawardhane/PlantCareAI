
import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    // MARK: - Request Permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .badge, .sound]
            ) { granted, error in

                if let error = error {
                    print("Notification permission error: \(error)")
                    return
                }

                print("Notification permission: \(granted)")
            }
    }

    // MARK: - Schedule Watering Reminder
    func scheduleWateringReminder(
        plantID: UUID,
        plantName: String,
        frequency: Int,
        lastWatered: Date
    ) {

        let center = UNUserNotificationCenter.current()
        let identifier = "watering-\(plantID.uuidString)"

        center.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )

        let safeFrequency = max(frequency, 1)

        guard let nextWateringDate = Calendar.current.date(
            byAdding: .day,
            value: safeFrequency,
            to: lastWatered
        ) else {
            return
        }

        var components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: nextWateringDate
        )

        components.hour = 9
        components.minute = 0
        components.second = 0

        guard let reminderDate = Calendar.current.date(
            from: components
        ) else {
            return
        }

        // If the calculated reminder is in the past,
        // schedule the next available 9 AM.
        var finalDate = reminderDate

        if finalDate <= Date() {
            let today = Calendar.current.startOfDay(for: Date())

            guard let todayAtNine = Calendar.current.date(
                byAdding: .hour,
                value: 9,
                to: today
            ) else {
                return
            }

            if todayAtNine > Date() {
                finalDate = todayAtNine
            } else {
                guard let tomorrow = Calendar.current.date(
                    byAdding: .day,
                    value: 1,
                    to: todayAtNine
                ) else {
                    return
                }

                finalDate = tomorrow
            }
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to Water Your Plant 🌿"
        content.body = "Your \(plantName) needs watering today!"
        content.sound = .default

        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: finalDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Scheduling error: \(error)")
            } else {
                print("Watering reminder scheduled for \(plantName)")
            }
        }
    }

    // MARK: - Cancel Reminder
    func cancelReminder(plantID: UUID) {

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [
                    "watering-\(plantID.uuidString)"
                ]
            )
    }
}
