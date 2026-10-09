
import SwiftUI
import CoreData

struct CareHistoryView: View {

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CareRecord.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var careRecords: FetchedResults<CareRecord>

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    var body: some View {
        NavigationStack {
            List {
                if careRecords.isEmpty {
                    ContentUnavailableView(
                        "No Care History Yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text(
                            "Your plant care activities will appear here."
                        )
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(careRecords, id: \.objectID) { record in
                        HStack(spacing: 15) {

                            Image(systemName: "drop.fill")
                                .font(.title2)
                                .foregroundStyle(primaryGreen)
                                .frame(width: 45, height: 45)
                                .background(
                                    primaryGreen.opacity(0.10)
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )

                            VStack(alignment: .leading, spacing: 6) {

                                Text(record.plantName ?? "Unknown Plant")
                                    .font(.headline)

                                Text(record.careType ?? "Plant Care")
                                    .font(.subheadline)
                                    .foregroundStyle(primaryGreen)

                                if let date = record.date {
                                    Text(
                                        date.formatted(
                                            date: .abbreviated,
                                            time: .shortened
                                        )
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(primaryGreen)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Care History")
        }
        .tint(primaryGreen)
    }
}

#Preview {
    CareHistoryView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
