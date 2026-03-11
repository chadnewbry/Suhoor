import SwiftUI

struct SehriChecklistView: View {
    @ObservedObject var checklistService: SehriChecklistService
    @State private var showAddItem = false
    @State private var newItemTitle = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pre-Sehri Routine")
                        .font(.headline)
                        .foregroundStyle(Color.suhoorTextPrimary)
                    Text("\(checklistService.todayChecklist.completionCount)/\(checklistService.todayChecklist.items.count) completed")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
                Spacer()
                Button {
                    showAddItem.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(Color.suhoorGold)
                        .font(.title3)
                }
                .accessibilityIdentifier("addChecklistItem")
            }
            
            // Checklist items
            ForEach(checklistService.todayChecklist.items) { item in
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            checklistService.toggleItem(item)
                        }
                    } label: {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isCompleted ? Color.suhoorSuccess : Color.suhoorTextSecondary)
                            .font(.title3)
                    }
                    
                    Text(item.title)
                        .font(.subheadline)
                        .foregroundStyle(item.isCompleted ? Color.suhoorTextSecondary : Color.suhoorTextPrimary)
                        .strikethrough(item.isCompleted)
                    
                    Spacer()
                    
                    if !item.isDefault {
                        Button {
                            withAnimation {
                                checklistService.removeItem(item)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(Color.suhoorTextSecondary.opacity(0.5))
                                .font(.caption)
                        }
                    }
                    
                    Text("\(item.minutesBefore)m")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.suhoorTextSecondary)
                }
            }
            
            // Add item field
            if showAddItem {
                HStack {
                    TextField("New item...", text: $newItemTitle)
                        .textFieldStyle(.plain)
                        .foregroundStyle(Color.suhoorTextPrimary)
                        .font(.subheadline)
                    
                    Button("Add") {
                        guard !newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        checklistService.addCustomItem(title: newItemTitle)
                        newItemTitle = ""
                        showAddItem = false
                    }
                    .foregroundStyle(Color.suhoorGold)
                    .font(.subheadline.weight(.medium))
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.suhoorDivider)
                )
            }
            
            // Completion celebration
            if checklistService.todayChecklist.isFullyCompleted {
                HStack {
                    Spacer()
                    Text("✨ All done! May your fast be accepted.")
                        .font(.caption)
                        .foregroundStyle(Color.suhoorGold)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.suhoorSurface)
        )
        .accessibilityIdentifier("sehriChecklist")
    }
}

#Preview {
    ZStack {
        Color.suhoorIndigo.ignoresSafeArea()
        SehriChecklistView(checklistService: .shared)
            .padding()
    }
}
