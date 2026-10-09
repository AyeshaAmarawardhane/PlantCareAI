
import SwiftUI
import UserNotifications

struct SettingsView: View {

    @Environment(\.scenePhase) private var scenePhase

    @State private var notificationsEnabled = false
    @State private var notificationStatus = "Checking..."

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Notifications
                Section {
                    HStack {
                        Label(
                            "Watering Reminders",
                            systemImage: "bell.fill"
                        )

                        Spacer()

                        Text(notificationStatus)
                            .font(.caption)
                            .foregroundStyle(
                                notificationsEnabled ? .green : .orange
                            )
                    }

                    Button {
                        openAppSettings()
                    } label: {
                        Label(
                            "Manage Notification Permissions",
                            systemImage: "gearshape"
                        )
                    }

                    Button {
                        sendTestNotification()
                    } label: {
                        Label(
                            "Test Notification (5 Seconds)",
                            systemImage: "bell.badge"
                        )
                    }
                    .disabled(!notificationsEnabled)

                } header: {
                    Text("Notifications")
                } footer: {
                    Text(
                        "Watering reminders are currently scheduled for 9:00 AM. You can manage notification permissions in iPhone Settings."
                    )
                }

                // MARK: - Plant Care
                Section("Plant Care") {
                    Label(
                        "Watering schedules are based on each plant's selected frequency.",
                        systemImage: "drop.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // MARK: - About
                Section("About") {
                    LabeledContent(
                        "Application",
                        value: "PlantCare AI"
                    )

                    LabeledContent(
                        "Version",
                        value: "1.0"
                    )

                    LabeledContent(
                        "Platform",
                        value: "iOS"
                    )
                }
            }
            .navigationTitle("Settings")
            .tint(primaryGreen)
            .onAppear {
                checkNotificationPermission()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    checkNotificationPermission()
                }
            }
        }
    }

    // MARK: - Check Permission
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in

                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .authorized, .provisional, .ephemeral:
                        notificationsEnabled = true
                        notificationStatus = "Enabled"

                    case .denied:
                        notificationsEnabled = false
                        notificationStatus = "Disabled"

                    case .notDetermined:
                        notificationsEnabled = false
                        notificationStatus = "Not Allowed Yet"

                    @unknown default:
                        notificationsEnabled = false
                        notificationStatus = "Unknown"
                    }
                }
            }
    }

    // MARK: - Open iOS Settings
    private func openAppSettings() {
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
            return
        }

        UIApplication.shared.open(url)
    }

    // MARK: - Test Notification
    private func sendTestNotification() {

        let content = UNMutableNotificationContent()
        content.title = "PlantCare AI 🌿"
        content.body = "Your watering reminders are working!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "plantcare-test",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current()
            .add(request) { error in

                if let error = error {
                    print(
                        "Test notification error: \(error.localizedDescription)"
                    )
                } else {
                    print("Test notification scheduled.")
                }
            }
    }
}

#Preview {
    SettingsView()
}
