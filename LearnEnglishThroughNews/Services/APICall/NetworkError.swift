import Foundation

enum NetworkError: String, Error, LocalizedError {
    case invalidURL = "The URL is invalid."
    case invalidResponse = "Invilid response from the server."
    case invalidData = "The data received from the server is invalid."
}
