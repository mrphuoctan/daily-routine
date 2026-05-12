import SwiftUI
import SwiftData
import PDFKit

struct ExportReportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isGenerating = false
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    @State private var selectedPeriod: Period = .week
    
    enum Period: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case allTime = "All Time"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(Period.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Preview card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "doc.richtext")
                            .font(.title2)
                            .foregroundStyle(Color.theme.primary)
                        VStack(alignment: .leading) {
                            Text("Activity Report")
                                .font(.headline)
                            Text(selectedPeriod.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    
                    Divider()
                    
                    Text("Report includes:")
                        .font(.subheadline).fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ReportItem(icon: "chart.pie.fill", text: "Activity breakdown by category")
                        ReportItem(icon: "clock.fill", text: "Total hours per activity type")
                        ReportItem(icon: "checkmark.circle.fill", text: "Completion rates and streaks")
                        ReportItem(icon: "chart.bar.fill", text: "Planned vs actual time")
                        ReportItem(icon: "flame.fill", text: "Calorie tracking summary")
                        ReportItem(icon: "heart.fill", text: "Burnout risk assessment")
                    }
                }
                .cardStyle()
                .padding(.horizontal, AppConstants.screenPadding)
                
                // Generate button
                Button {
                    generatePDF()
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isGenerating ? "Generating..." : "Generate & Share PDF")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.theme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius))
                }
                .disabled(isGenerating)
                .padding(.horizontal, AppConstants.screenPadding)
            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Export Report")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func generatePDF() {
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let startDate: Date
            switch selectedPeriod {
            case .week: startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            case .month: startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            case .allTime: startDate = Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()
            }
            
            // Fetch data on main thread
            DispatchQueue.main.async {
                let schedules = (try? modelContext.fetch(FetchDescriptor<DailySchedule>(
                    predicate: #Predicate<DailySchedule> { $0.date >= startDate }
                ))) ?? []
                
                let calories = (try? modelContext.fetch(FetchDescriptor<CalorieEntry>(
                    predicate: #Predicate<CalorieEntry> { $0.time >= startDate }
                ))) ?? []
                
                let url = PDFGenerator.generate(
                    schedules: schedules,
                    calories: calories,
                    period: selectedPeriod.rawValue
                )
                
                pdfURL = url
                isGenerating = false
                if url != nil { showShareSheet = true }
            }
        }
    }
}

struct ReportItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.theme.primary)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - PDF Generator
enum PDFGenerator {
    static func generate(schedules: [DailySchedule], calories: [CalorieEntry], period: String) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("DailyRoutine_Report.pdf")
        
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                
                let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
                let headingFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
                let bodyFont = UIFont.systemFont(ofSize: 12, weight: .regular)
                let smallFont = UIFont.systemFont(ofSize: 10, weight: .regular)
                
                var y: CGFloat = 40
                let margin: CGFloat = 40
                let width = 612 - margin * 2
                
                // Title
                let title = "Daily Routine Report"
                title.draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: titleFont])
                y += 35
                
                let subtitle = "\(period) — Generated \(Date().formatted(date: .abbreviated, time: .shortened))"
                subtitle.draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: smallFont, .foregroundColor: UIColor.secondaryLabel])
                y += 30
                
                // Stats section
                drawLine(context: context.cgContext, y: y, width: width, margin: margin)
                y += 15
                
                "Summary".draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: headingFont])
                y += 25
                
                let completed = schedules.filter { $0.completionStatus == .completed }.count
                let total = schedules.count
                let rate = total > 0 ? Int(Double(completed) / Double(total) * 100) : 0
                
                let stats = [
                    "Total Activities: \(total)",
                    "Completed: \(completed)",
                    "Completion Rate: \(rate)%",
                    "Unique Days: \(Set(schedules.map { Calendar.current.startOfDay(for: $0.date) }).count)"
                ]
                
                for stat in stats {
                    stat.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [.font: bodyFont])
                    y += 18
                }
                y += 10
                
                // Category breakdown
                drawLine(context: context.cgContext, y: y, width: width, margin: margin)
                y += 15
                "Activity Breakdown".draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: headingFont])
                y += 25
                
                let grouped = Dictionary(grouping: schedules) { $0.activity.rawValue }
                let sorted = grouped.sorted { $0.value.count > $1.value.count }
                
                for (activity, logs) in sorted.prefix(10) {
                    let completedInCat = logs.filter { $0.completionStatus == .completed }.count
                    let line = "\(activity): \(logs.count) sessions (\(completedInCat) completed)"
                    line.draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [.font: bodyFont])
                    y += 18
                    
                    if y > 720 {
                        context.beginPage()
                        y = 40
                    }
                }
                y += 10
                
                // Calorie section
                if !calories.isEmpty {
                    drawLine(context: context.cgContext, y: y, width: width, margin: margin)
                    y += 15
                    "Calorie Summary".draw(at: CGPoint(x: margin, y: y), withAttributes: [.font: headingFont])
                    y += 25
                    
                    let consumed = calories.filter { $0.isConsumed }.reduce(0) { $0 + $1.calories }
                    let burned = calories.filter { !$0.isConsumed }.reduce(0) { $0 + $1.calories }
                    
                    "Total Consumed: \(consumed) kcal".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [.font: bodyFont])
                    y += 18
                    "Total Burned: \(burned) kcal".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [.font: bodyFont])
                    y += 18
                    "Net: \(consumed - burned) kcal".draw(at: CGPoint(x: margin + 10, y: y), withAttributes: [.font: bodyFont])
                    y += 18
                }
                
                // Footer
                let footer = "Generated by Daily Routine App"
                footer.draw(at: CGPoint(x: margin, y: 760), withAttributes: [.font: smallFont, .foregroundColor: UIColor.tertiaryLabel])
            }
            return url
        } catch {
            print("PDF generation failed: \(error)")
            return nil
        }
    }
    
    private static func drawLine(context: CGContext, y: CGFloat, width: CGFloat, margin: CGFloat) {
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: margin, y: y))
        context.addLine(to: CGPoint(x: margin + width, y: y))
        context.strokePath()
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
