import SwiftUI

struct CalorieEntryForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var caloriesText = ""
    @State private var isConsumed = true
    @State private var note = ""
    
    var existing: CalorieEntry?
    var onSave: (String, Double, Bool, String) -> Void
    
    init(existing: CalorieEntry? = nil, onSave: @escaping (String, Double, Bool, String) -> Void) {
        self.existing = existing
        self.onSave = onSave
        if let e = existing {
            _name = State(initialValue: e.name)
            _caloriesText = State(initialValue: String(Int(e.calories)))
            _isConsumed = State(initialValue: e.isConsumed)
            _note = State(initialValue: e.note)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Entry Type") {
                    Picker("Type", selection: $isConsumed) {
                        Text("Food / Drink").tag(true)
                        Text("Exercise").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Name (e.g. Chicken rice)", text: $name)
                    TextField("Calories (kcal)", text: $caloriesText)
                        .keyboardType(.numberPad)
                    TextField("Note (optional)", text: $note)
                }
                
                Section("Quick Add") {
                    quickAddButtons
                }
            }
            .navigationTitle(existing == nil ? "Add Calorie Entry" : "Edit Calorie Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let cals = Double(caloriesText), !name.isEmpty {
                            onSave(name, cals, isConsumed, note)
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || caloriesText.isEmpty)
                }
            }
        }
    }
    
    private var quickAddButtons: some View {
        let presets: [(String, Int, Bool)] = [
            ("Chicken rice", 650, true),
            ("Protein shake", 220, true),
            ("Running 30m", 350, false),
            ("Pho", 450, true),
            ("Coffee", 50, true),
            ("Gym session", 400, false),
        ]
        
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(presets, id: \.0) { preset in
                Button {
                    name = preset.0
                    caloriesText = "\(preset.1)"
                    isConsumed = preset.2
                } label: {
                    VStack(spacing: 4) {
                        Text(preset.0)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text("\(preset.2 ? "+" : "-")\(preset.1) kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
