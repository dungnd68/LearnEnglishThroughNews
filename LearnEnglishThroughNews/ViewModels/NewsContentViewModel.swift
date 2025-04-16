import Foundation

@MainActor
class NewsContentViewModel: ObservableObject {
    @Published var extractNews: WorldNews?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var listTextContent: [String] = []

    func fetchElementUrlnews(newsUrl: String) async {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                extractNews = try await NetworkManager.shared.getElementUrlNews(newsUrl: newsUrl)
                listTextContent = extractNews?.text?.split(separator: "\n\n").map(String.init) ?? []
            } catch {
                if let error = error as? NetworkError {
                    print(error)
                    errorMessage = error.localizedDescription
                }
            }
            isLoading = false
        }
    }
    
}
