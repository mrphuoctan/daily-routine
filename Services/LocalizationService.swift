import Foundation
import SwiftUI

class LocalizationService: ObservableObject {
    static let shared = LocalizationService()
    
    enum Language: String, CaseIterable {
        case english = "en"
        case vietnamese = "vi"
        case chinese = "zh-Hans"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .vietnamese: return "Tiếng Việt"
            case .chinese: return "简体中文"
            }
        }
        
        var locale: Locale {
            Locale(identifier: rawValue)
        }
        
        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            case .vietnamese: return "🇻🇳"
            case .chinese: return "🇨🇳"
            }
        }
    }
    
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
            Bundle.setLanguage(currentLanguage.rawValue)
        }
    }
    
    init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.currentLanguage = Language(rawValue: saved) ?? .english
        Bundle.setLanguage(currentLanguage.rawValue)
    }
    
    func localized(_ key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj")
        let bundle = path != nil ? (Bundle(path: path!) ?? Bundle.main) : Bundle.main
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
    
    /// Localize notification text - falls back to original string if no key found
    func localizedNotification(_ text: String) -> String {
        let key = "notif_\(text.lowercased().replacingOccurrences(of: " ", with: "_"))"
        let result = localized(key)
        // If key not found (returns same key), use original text
        return result == key ? text : result
    }
    
    var locale: Locale {
        currentLanguage.locale
    }
}

// MARK: - Bundle Extension for Language Switching
private var bundleKey: UInt8 = 0

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        objc_setAssociatedObject(
            Bundle.main,
            &bundleKey,
            Bundle.main.path(forResource: language, ofType: "lproj"),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

class AnyLanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
