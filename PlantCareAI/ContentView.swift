
import SwiftUI
import CoreData

struct ContentView: View {

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Plant.dateAdded, ascending: false)
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

            // MARK: Home
            homeScreen
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            // MARK: My Garden
            MyGardenView()
                .tabItem {
                    Label("My Garden", systemImage: "leaf.fill")
                }

            // MARK: Scan
            PlantScannerView()
            
            .tabItem {
                Label("Scan", systemImage: "camera.fill")
            }

            // MARK: History
            placeholderScreen(
                title: "Care History",
                icon: "calendar",
                message: "Track your plant care activities."
            )
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }

            // MARK: Settings
            placeholderScreen(
                title: "Settings",
                icon: "gearshape.fill",
                message: "Customize your PlantCare AI experience."
            )
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

                    // Welcome Header
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

                    // AI Scanner Card
                    VStack(alignment: .leading, spacing: 15) {

                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 42))

                        Text("Discover Your Plants")
                            .font(.title2.bold())

                        Text("Take a photo of a plant and let AI help you identify it.")
                            .font(.subheadline)

                        Text("Tap the Scan tab to get started")
                            .font(.caption.bold())
                            .padding(10)
                            .background(.white.opacity(0.20))
                            .clipShape(Capsule())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [
                                primaryGreen,
                                Color(red: 0.29, green: 0.69, blue: 0.48)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                    // Garden Overview
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

                    // Today's Care
                    Text("Today's Care")
                        .font(.title2.bold())

                    VStack(spacing: 12) {

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(primaryGreen)

                        Text(
                            plants.isEmpty
                            ? "All caught up!"
                            : "Keep Your Garden Healthy!"
                        )
                        .font(.headline)

                        Text(
                            plants.isEmpty
                            ? "Add your first plant to start tracking its care."
                            : "Visit My Garden to manage your plants and watering schedules."
                        )
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
                .padding()
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            Color(.secondarySystemGroupedBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }

    // MARK: - Placeholder Screens
    private func placeholderScreen(
        title: String,
        icon: String,
        message: String
    ) -> some View {

        NavigationStack {
            VStack(spacing: 18) {

                Image(systemName: icon)
                    .font(.system(size: 65))
                    .foregroundStyle(primaryGreen)

                Text(title)
                    .font(.title.bold())

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color(.systemGroupedBackground)
            )
            .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
