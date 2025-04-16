import SwiftUI
import Translation

struct NewsContentView: View {
    @StateObject var newsContentViewModel = NewsContentViewModel()
    @State private var showTranslation = false
    @State private var targetText = ""
    @State private var configuration: TranslationSession.Configuration?

    let article: Article

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = article.urlToImage,
                    let url = URL(string: imageUrl)
                {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                if newsContentViewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 150)
                } else {
                    Button("Dịch toàn bộ") {
                        showTranslation.toggle()
                    }

                    Text(article.title)
                        .font(.title)
                        .bold()

                    HStack {
                        Spacer()
                        Button {
                            triggerTranslation()
                        } label: {
                            Image(systemName: "translate")
                        }
                        Spacer()
                    }
                    
                    Text(verbatim: targetText)
                        .foregroundStyle(.gray)

                    ForEach(newsContentViewModel.listTextContent, id: \.self) { text in
                        TextContentView(text: text)
                    }
                }
            }
            .translationPresentation(isPresented: $showTranslation, text: newsContentViewModel.extractNews?.text ?? "Đang tải...")
            .translationTask(configuration) { session in
                do {
                    let response = try await session.translate(article.title)
                    targetText = response.targetText
                } catch {
                    // Handle any errors.
                }
            }
            .padding()
        }
        .onAppear {
            if newsContentViewModel.extractNews == nil {
                Task {
                    await newsContentViewModel.fetchElementUrlnews(newsUrl: article.url)
                }
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

//struct NewsContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsContentView()
//    }
//}
