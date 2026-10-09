
import SwiftUI
import PhotosUI

struct PlantScannerView: View {

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var plantImage: UIImage?
    @State private var isLoading = false

    private let primaryGreen = Color(
        red: 0.13,
        green: 0.48,
        blue: 0.30
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // MARK: - Scanner Header

                    Image(systemName: "camera.macro")
                        .font(.system(size: 50))
                        .foregroundStyle(primaryGreen)
                        .padding(.top, 10)

                    Text("Identify Your Plant")
                        .font(.title2.bold())

                    Text("Upload a plant photo to discover its identity and care needs.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    // MARK: - Plant Image Preview

                    if let plantImage {
                        Image(uiImage: plantImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 240)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 20)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green.opacity(0.08))
                            .frame(height: 200)
                            .overlay {
                                Image(systemName: "leaf")
                                    .font(.system(size: 65))
                                    .foregroundStyle(primaryGreen)
                            }
                    }

                    // MARK: - Choose Plant Photo

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            "Choose Plant Photo",
                            systemImage: "photo.on.rectangle"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryGreen)
                        .foregroundStyle(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                    }
                    .onChange(of: selectedPhoto) { _, newPhoto in
                        Task {
                            plantImage = nil

                            if let data = try? await newPhoto?
                                .loadTransferable(type: Data.self) {

                                plantImage = UIImage(data: data)
                            }
                        }
                    }

                    // MARK: - Identify Plant Button

                    if plantImage != nil {
                        NavigationLink {
                            PlantIdentificationResultView(
                                plantImage: plantImage!
                            )
                        } label: {                            Label(
                                "Identify Plant",
                                systemImage: "sparkles"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(primaryGreen)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Scan Plant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PlantScannerView()
}
