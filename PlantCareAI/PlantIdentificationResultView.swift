
import SwiftUI
import CoreData

struct PlantIdentificationResultView: View {

    let plantImage: UIImage

    @Environment(\.managedObjectContext)
    private var viewContext

    @State private var isSaved = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage = ""

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    // Demo data - Replace with AI results later
    private let plantName = "Rose"
    private let scientificName = "Rosa"
    private let wateringDays = 3

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Plant Image

                Image(uiImage: plantImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 260)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )

                // MARK: - Demo Notice

                Label(
                    "Demo Result - AI not connected yet",
                    systemImage: "info.circle"
                )
                .font(.caption)
                .foregroundStyle(.orange)

                // MARK: - Plant Identity

                VStack(alignment: .leading, spacing: 8) {

                    Text(plantName)
                        .font(.largeTitle.bold())

                    Text("Scientific Name: \(scientificName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(
                        "A popular flowering plant known for its beautiful and fragrant flowers."
                    )
                    .font(.body)
                }

                Divider()

                Text("Plant Care Guide")
                    .font(.title2.bold())

                // MARK: - Care Information

                careCard(
                    icon: "drop.fill",
                    title: "Watering",
                    description: "Water every 3 days. Adjust based on soil moisture."
                )

                careCard(
                    icon: "sun.max.fill",
                    title: "Sunlight",
                    description: "Provide approximately 6 hours of direct sunlight daily."
                )

                careCard(
                    icon: "leaf.fill",
                    title: "Soil",
                    description: "Use well-draining, nutrient-rich soil."
                )

                careCard(
                    icon: "heart.text.square.fill",
                    title: "Care Tips",
                    description: "Remove dead flowers and monitor for pests."
                )

                // MARK: - Add to My Garden

                Button {
                    savePlantToGarden()
                } label: {
                    Label(
                        isSaved ? "Added to My Garden" : "Add to My Garden",
                        systemImage: isSaved
                            ? "checkmark.circle.fill"
                            : "plus.circle.fill"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryGreen)
                .disabled(isSaved)
                .padding(.top, 10)

                if isSaved {
                    Label(
                        "Plant saved successfully! Open My Garden to view it.",
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.subheadline)
                    .foregroundStyle(primaryGreen)
                }
            }
            .padding(20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plant Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Unable to Save Plant", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    // MARK: - Save Plant to Core Data

    private func savePlantToGarden() {

        guard !isSaved else { return }

        let newPlant = Plant(context: viewContext)

        newPlant.id = UUID()
        newPlant.name = plantName
        newPlant.species = scientificName
        newPlant.notes = "Added from plant identification demo."
        newPlant.wateringFrequency = Int16(wateringDays)
        newPlant.dateAdded = Date()

        // Not watered yet
        newPlant.lastWatered = nil

        do {
            try viewContext.save()
            isSaved = true

            print("Plant saved successfully: \(plantName)")

        } catch {
            viewContext.rollback()

            saveErrorMessage = error.localizedDescription
            showingSaveError = true

            print("Plant save error: \(error.localizedDescription)")
        }
    }

    // MARK: - Care Card

    private func careCard(
        icon: String,
        title: String,
        description: String
    ) -> some View {

        HStack(alignment: .top, spacing: 15) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(primaryGreen)
                .frame(width: 35)

            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

#Preview {
    NavigationStack {
        PlantIdentificationResultView(
            plantImage: UIImage(systemName: "leaf.fill")!
        )
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
    }
}
