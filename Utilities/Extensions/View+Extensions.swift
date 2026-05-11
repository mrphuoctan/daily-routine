import SwiftUI

// MARK: - Card Style Modifier
struct CardModifier: ViewModifier {
    var padding: CGFloat = AppConstants.cardPadding
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppConstants.cornerRadius
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        phase = UIScreen.main.bounds.width
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func cardStyle(padding: CGFloat = AppConstants.cardPadding) -> some View {
        modifier(CardModifier(padding: padding))
    }
    
    func glassCard(cornerRadius: CGFloat = AppConstants.cornerRadius) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}
