import Foundation
import Translation

final class NetworkManager {
    static let shared = NetworkManager()

    func getNews() async throws -> [Article] {
        guard let url = URL(string: "\(BASEURL_NEWSAPI)?country=us&apiKey=\(NEWS_APIKEY)") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(News.self, from: data).articles
        } catch {
            throw NetworkError.invalidURL
        }
    }

    func getElementUrlNews(newsUrl: String) async throws -> WorldNews {
        guard let url = URL(string: "\(BASEURL_WORLDNEWS)?url=\(newsUrl)&api-key=\(WORLDNEWS_APIKEY4)") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(WorldNews.self, from: data)
        } catch {
            throw NetworkError.invalidURL
        }
    }
}
