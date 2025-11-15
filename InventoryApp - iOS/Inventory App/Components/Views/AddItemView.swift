//
//  AddItemView.swift
//  Inventory App
//
//  Created by Connor Bailey on 11/14/25.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var location: String = ""
    
    let onSave: (String, Int, String) -> Void
    
    private var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard Int(quantity.trimmingCharacters(in: .whitespaces)) != nil else { return false }
        return true
    }
    
    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let qtyInt = Int(quantity.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        
        onSave(trimmedName, qtyInt, trimmedLocation)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    TextField("Quantity", text: $quantity)
                        .keyboardType(.numberPad)
                    
                    TextField("Location", text: $location)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

#Preview {
    AddItemView { _, _, _ in }
}
