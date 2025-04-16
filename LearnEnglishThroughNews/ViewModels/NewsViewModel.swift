import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    
    init() {
        fetchNews()
    }
    
    func fetchNews() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                articles = try await NetworkManager.shared.getNews()
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
