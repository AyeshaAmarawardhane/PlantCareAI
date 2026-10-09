
import SwiftUI
import CoreData

struct ContentView: View {

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \Plant.dateAdded,
                ascending: false
            )
        ],
        animation: .default
    )
    private var plants: FetchedResults<Plant>

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    var body: some View {
        TabView {

            // MARK: - Home
            homeScreen
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // MARK: - My Garden
            MyGardenView()
                .tabItem {
                    Label("My Garden", systemImage: "leaf.fill")
                }

            // MARK: - Scan
            PlantScannerView()
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }

            // MARK: - History
            CareHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            // MARK: - Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(primaryGreen)
    }

    // MARK: - Home Screen

    private var homeScreen: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Welcome Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {

                            Text("Welcome to")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("PlantCare AI 🌿")
                                .font(.largeTitle.bold())
                                .foregroundStyle(primaryGreen)

                            Text("Your smart plant care companion")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(primaryGreen)
                    }

                    // MARK: AI Scanner Card
                    VStack(alignment: .leading, spacing: 15) {

                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 42))

                        Text("Discover Your Plants")
                            .font(.title2.bold())

                        Text(
                            "Take a photo of a plant and let AI help you identify it."
                        )
                        .font(.subheadline)

                        Text("Tap the Scan tab to get started")
                            .font(.caption.bold())
                            .padding(10)
                            .background(.white.opacity(0.20))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [
                                primaryGreen,
                                Color(
                                    red: 0.29,
                                    green: 0.69,
                                    blue: 0.48
                                )
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )

                    // MARK: Garden Overview
                    Text("Your Garden Overview")
                        .font(.title2.bold())

                    HStack(spacing: 14) {

                        statCard(
                            title: "Total Plants",
                            value: "\(plants.count)",
                            icon: "leaf.fill"
                        )

                        statCard(
                            title: "Watered Today",
                            value: "\(wateredTodayCount)",
                            icon: "drop.fill"
                        )
                    }

                    // MARK: Today's Care
                    Text("Today's Care")
                        .font(.title2.bold())

                    if plants.isEmpty {

                        careMessage(
                            icon: "leaf.circle.fill",
                            title: "Your Garden is Empty",
                            message: "Add your first plant to start tracking its care."
                        )

                    } else {

                        let duePlants = plants.filter {
                            isWateringDue($0)
                        }

                        if duePlants.isEmpty {

                            careMessage(
                                icon: "checkmark.circle.fill",
                                title: "All Caught Up!",
                                message: "Your plants are up to date with their watering schedules."
                            )

                        } else {

                            VStack(spacing: 12) {

                                ForEach(duePlants, id: \.objectID) { plant in

                                    HStack(spacing: 14) {

                                        Image(systemName: "drop.fill")
                                            .font(.title2)
                                            .foregroundStyle(primaryGreen)
                                            .frame(width: 35)

                                        VStack(
                                            alignment: .leading,
                                            spacing: 6
                                        ) {

                                            Text(
                                                plant.name ?? "Unnamed Plant"
                                            )
                                            .font(.headline)

                                            Text("Watering Needed")
                                                .font(.subheadline)
                                                .foregroundStyle(.orange)

                                            Text(
                                                wateringStatus(for: plant)
                                            )
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Image(
                                            systemName: "exclamationmark.circle.fill"
                                        )
                                        .font(.title2)
                                        .foregroundStyle(.orange)
                                    }
                                    .padding(18)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .background(
                                        Color(.secondarySystemGroupedBackground)
                                    )
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 18)
                                    )
                                }
                            }
                        }
                    }

                    // MARK: Upcoming Watering
                    if !plants.isEmpty {

                        Text("Upcoming Watering")
                            .font(.title2.bold())

                        VStack(spacing: 12) {

                            ForEach(
                                plants.filter {
                                    !isWateringDue($0)
                                },
                                id: \.objectID
                            ) { plant in

                                HStack(spacing: 14) {

                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundStyle(primaryGreen)

                                    VStack(
                                        alignment: .leading,
                                        spacing: 5
                                    ) {

                                        Text(
                                            plant.name ?? "Unnamed Plant"
                                        )
                                        .font(.headline)

                                        Text(
                                            wateringStatus(for: plant)
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(primaryGreen)
                                }
                                .padding()
                                .background(
                                    Color(.secondarySystemGroupedBackground)
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 18)
                                )
                            }
                        }
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
        }
    }

    // MARK: - Watering Statistics

    private var wateredTodayCount: Int {

        plants.filter { plant in

            guard let date = plant.lastWatered else {
                return false
            }

            return Calendar.current.isDateInToday(date)

        }.count
    }

    // MARK: - Watering Due Calculation

    private func isWateringDue(_ plant: Plant) -> Bool {

        guard let lastWatered = plant.lastWatered else {
            return true
        }

        let frequency = max(
            Int(plant.wateringFrequency),
            1
        )

        guard let nextWateringDate = Calendar.current.date(
            byAdding: .day,
            value: frequency,
            to: lastWatered
        ) else {
            return false
        }

        return Calendar.current.startOfDay(
            for: nextWateringDate
        ) <= Calendar.current.startOfDay(for: Date())
    }

    // MARK: - Watering Status

    private func wateringStatus(for plant: Plant) -> String {

        guard let lastWatered = plant.lastWatered else {
            return "Not watered yet"
        }

        let frequency = max(
            Int(plant.wateringFrequency),
            1
        )

        guard let nextWateringDate = Calendar.current.date(
            byAdding: .day,
            value: frequency,
            to: lastWatered
        ) else {
            return "Schedule unavailable"
        }

        let today = Calendar.current.startOfDay(for: Date())

        let nextDay = Calendar.current.startOfDay(
            for: nextWateringDate
        )

        let daysDifference = Calendar.current.dateComponents(
            [.day],
            from: today,
            to: nextDay
        ).day ?? 0

        if daysDifference < 0 {
            return "Overdue by \(abs(daysDifference)) day(s)"
        } else if daysDifference == 0 {
            return "Water today"
        } else if daysDifference == 1 {
            return "Water tomorrow"
        } else {
            return "Next watering in \(daysDifference) days"
        }
    }

    // MARK: - Statistics Card

    private func statCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(primaryGreen)

            Text(value)
                .font(.largeTitle.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Care Message Card

    private func careMessage(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        VStack(spacing: 12) {

            Image(systemName: icon)
                .font(.system(size: 42))
                .foregroundStyle(primaryGreen)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
