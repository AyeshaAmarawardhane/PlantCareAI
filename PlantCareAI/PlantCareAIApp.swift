
import SwiftUI
import CoreData

@main
struct PlantCareAIApp: App {

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                .onAppear {
                    NotificationManager.shared.requestPermission()
                }
        }
    }
}
