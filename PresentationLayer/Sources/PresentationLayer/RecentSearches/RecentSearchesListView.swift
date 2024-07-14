import SwiftUI
import SwiftData

struct RecentSearchesListView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \SearchLocation.timeStamp, order: .reverse, animation: .smooth)
    var recentLocations: [SearchLocation]

    // MARK: - UI Body

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(recentLocations) { item in
                        NavigationLink {
                            WeatherDetailView(cityName: item.name)
                        } label: {
                            HStack {
                                Text(item.name)
                                    .foregroundStyle(.white)
                            }
                        }
                        .listRowBackground(
                            Rectangle()
                                .foregroundStyle(.thinMaterial.opacity(0.5))
                                .contentShape(Rectangle()))

                    }
                    .onDelete(perform: deleteItems)

                } header: {
                    Text("Recently searched locations")
                        .foregroundStyle(.white)
                }
            }
            .scrollContentBackground(.hidden)
            .background(DarkGradientView())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(Color.white)
                }
            }
            .navigationTitle("")
        }
    }

    // MARK: - Private Methods
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(recentLocations[index])
            }
        }
    }

}

#Preview {
    RecentSearchesListView()
        .modelContainer(for: SearchLocation.self, inMemory: true)
}
