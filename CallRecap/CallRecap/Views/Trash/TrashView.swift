import SwiftUI

struct TrashView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var deletedRecordings: [Recording] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if deletedRecordings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "trash")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Trash is Empty")
                            .font(.headline)
                        Text("Deleted recordings appear here for 30 days.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                } else {
                    ForEach(deletedRecordings) { recording in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recording.contactName ?? "Unknown")
                                    .font(.headline)
                                Text("Deleted \(recording.deletedAt?.formattedShort ?? "recently")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(recording.formattedDuration)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                dataManager.permanentDelete(recording)
                                loadDeleted()
                            } label: {
                                Label("Delete Forever", systemImage: "trash.fill")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                dataManager.restore(recording)
                                loadDeleted()
                            } label: {
                                Label("Restore", systemImage: "arrow.uturn.backward")
                            }
                            .tint(.green)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Trash")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear { loadDeleted() }
    }

    private func loadDeleted() {
        deletedRecordings = dataManager.fetchDeletedRecordings()
    }
}
