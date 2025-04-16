import SwiftUI
import Translation

struct TextContentView: View {
    let text: String
    @State private var targetText = ""
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        VStack {    
            WordTranslateView(text: text)

            Button {
                triggerTranslation()
            } label: {
                Image(systemName: "translate")
            }

            Text(verbatim: targetText)
                .foregroundStyle(.gray)
        }
        .translationTask(configuration) { session in
            do {
                let response = try await session.translate(text)
                targetText = response.targetText
            } catch {
                // Handle any errors.
            }
        }
    }

    private func triggerTranslation() {
        if configuration == nil {
              configuration = .init(source: Locale.Language(identifier: "en_US"),
                                    target: Locale.Language(identifier: "vi_VN"))
          } else {
              configuration?.invalidate()
          }
    }
}
