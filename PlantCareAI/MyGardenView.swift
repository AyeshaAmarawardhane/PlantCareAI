
import SwiftUI
import CoreData

struct MyGardenView: View {

    @Environment(\.managedObjectContext)
    private var viewContext

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

    @State private var showingAddPlant = false
    @State private var errorMessage: String?
    @State private var showingError = false

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    var body: some View {
        NavigationStack {
            List {
                if plants.isEmpty {
                    ContentUnavailableView(
                        "Your Garden is Empty",
                        systemImage: "leaf",
                        description: Text(
                            "Add your first plant to get started."
                        )
                    )
                    .listRowBackground(Color.clear)

                } else {
                    ForEach(plants, id: \.objectID) { plant in

                        VStack(alignment: .leading, spacing: 12) {

                            Text(plant.name ?? "Unnamed Plant")
                                .font(.headline)

                            Text(plant.species ?? "Unknown species")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Label(
                                "Water every \(plant.wateringFrequency) days",
                                systemImage: "drop.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(primaryGreen)

                            if let date = plant.dateAdded {
                                Text(
                                    "Added: \(date.formatted(date: .abbreviated, time: .omitted))"
                                )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }

                            if let lastWatered = plant.lastWatered {
                                Label(
                                    "Last watered: \(lastWatered.formatted(date: .abbreviated, time: .omitted))",
                                    systemImage: "calendar"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            } else {
                                Text("Not watered yet")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Button {
                                markAsWatered(plant)
                            } label: {
                                Label(
                                    isWateredToday(plant)
                                    ? "Watered Today"
                                    : "Mark as Watered",
                                    systemImage: isWateredToday(plant)
                                    ? "checkmark.circle.fill"
                                    : "drop.fill"
                                )
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(primaryGreen)
                            .disabled(isWateredToday(plant))
                            .padding(.top, 5)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: deletePlants)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Garden")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(primaryGreen)
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantView()
            }
            .alert("Unable to Save", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unexpected error occurred.")
            }
        }
        .tint(primaryGreen)
    }

    // MARK: - Check Watering Status

    private func isWateredToday(_ plant: Plant) -> Bool {
        guard let lastWatered = plant.lastWatered else {
            return false
        }

        return Calendar.current.isDateInToday(lastWatered)
    }

    // MARK: - Mark Plant as Watered

    private func markAsWatered(_ plant: Plant) {

        guard !isWateredToday(plant) else {
            return
        }

        let now = Date()

        if plant.id == nil {
            plant.id = UUID()
        }

        let careRecord = CareRecord(context: viewContext)

        careRecord.id = UUID()
        careRecord.plantID = plant.id
        careRecord.plantName = plant.name ?? "Unnamed Plant"
        careRecord.careType = "Watering"
        careRecord.date = now

        plant.lastWatered = now

        do {
            try viewContext.save()

            // Schedule next watering reminder
            if let plantID = plant.id {
                NotificationManager.shared.scheduleWateringReminder(
                    plantID: plantID,
                    plantName: plant.name ?? "Unnamed Plant",
                    frequency: Int(plant.wateringFrequency),
                    lastWatered: now
                )
            }

            print("Plant watered and next reminder requested.")

        } catch {
            viewContext.rollback()

            errorMessage = error.localizedDescription
            showingError = true

            print("Watering save error: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Plants

    private func deletePlants(at offsets: IndexSet) {

        let plantsToDelete = offsets.map { plants[$0] }

        let plantIDs = plantsToDelete.compactMap { $0.id }

        for plant in plantsToDelete {
            viewContext.delete(plant)
        }

        do {
            try viewContext.save()

            // Cancel reminders after successful deletion
            for plantID in plantIDs {
                NotificationManager.shared.cancelReminder(
                    plantID: plantID
                )
            }

            print("Plants deleted and reminders cancelled.")

        } catch {
            viewContext.rollback()

            errorMessage = error.localizedDescription
            showingError = true

            print("Delete error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Manual Add Plant

struct AddPlantView: View {

    @Environment(\.managedObjectContext)
    private var viewContext

    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""
    @State private var species = ""
    @State private var notes = ""
    @State private var wateringFrequency = 3

    @State private var errorMessage: String?
    @State private var showingError = false

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant Information") {
                    TextField("Plant Name", text: $name)
                    TextField("Species", text: $species)
                    TextField("Notes", text: $notes)
                }

                Section("Watering Schedule") {
                    Stepper(
                        "Every \(wateringFrequency) days",
                        value: $wateringFrequency,
                        in: 1...30
                    )
                }
            }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePlant()
                    }
                    .disabled(
                        name.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
            .alert("Unable to Save Plant", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An unexpected error occurred.")
            }
        }
        .tint(primaryGreen)
    }

    // MARK: - Save Plant

    private func savePlant() {

        let plant = Plant(context: viewContext)

        plant.id = UUID()
        plant.name = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        plant.species = species
        plant.notes = notes
        plant.wateringFrequency = Int16(wateringFrequency)
        plant.dateAdded = Date()
        plant.lastWatered = nil

        do {
            try viewContext.save()

            // Schedule first watering reminder
            if let plantID = plant.id,
               let dateAdded = plant.dateAdded {

                NotificationManager.shared.scheduleWateringReminder(
                    plantID: plantID,
                    plantName: plant.name ?? "Unnamed Plant",
                    frequency: Int(plant.wateringFrequency),
                    lastWatered: dateAdded
                )
            }

            print("Plant saved and first reminder requested.")

            dismiss()

        } catch {
            viewContext.rollback()

            errorMessage = error.localizedDescription
            showingError = true

            print("Save error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview

#Preview {
    MyGardenView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
