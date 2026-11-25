import SwiftUI
#if canImport(LiquidGlass)
import LiquidGlass
#endif

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
    static let sileoTint = Color(hex: 0x2CB1BE)
}

/// 全应用唯一的玻璃效果入口。
/// 在这里接入 LiquidGlass 库的视图/修饰器（见 README），
/// 未接入时：iOS 26+ 使用系统 glassEffect，其余使用毛玻璃材质。
struct GlassSurface: ViewModifier {
    var radius: CGFloat = 20

    @ViewBuilder
    func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        } else {
            content.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
        #else
        content.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        #endif
    }
}

extension View {
    func glass(_ radius: CGFloat = 20) -> some View { modifier(GlassSurface(radius: radius)) }
}

struct PkgIcon: View {
    let symbol: String
    let color: UInt
    var size: CGFloat = 60

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: size * 0.2237, style: .continuous)
        ZStack {
            shape.fill(Color(hex: color))
            shape.fill(LinearGradient(colors: [.white.opacity(0.28), .clear], startPoint: .top, endPoint: .bottom))
            Image(systemName: symbol)
                .font(.system(size: size * 0.46, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
        }
        .frame(width: size, height: size)
        .overlay(shape.strokeBorder(.white.opacity(0.15), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
    }
}

struct GetButton: View {
    let title: String
    var destructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 18).padding(.vertical, 7)
                .foregroundStyle(destructive ? Color.red : Color.sileoTint)
                .background((destructive ? Color.red : Color.sileoTint).opacity(0.14), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
