
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

                        VStack(alignment: .leading, spacing: 10) {

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
        }
        .tint(primaryGreen)
    }

    private func deletePlants(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(plants[index])
        }

        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
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
        }
    }

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
            dismiss()
        } catch {
            viewContext.rollback()
            print("Save error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MyGardenView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
