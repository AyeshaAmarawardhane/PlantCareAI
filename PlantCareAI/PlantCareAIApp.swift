//
//  PlantCareAIApp.swift
//  PlantCareAI
//
//  Created by Ayesha Amarawardhana on 2026-10-09.
//

import SwiftUI
import CoreData

@main
struct PlantCareAIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
