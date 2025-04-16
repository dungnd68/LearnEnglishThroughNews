import Foundation

struct WorldNews: Codable {
    let title, text: String?
    let url: String?
//    let image: String?
//    let images: [Image]?
    let video: String?
    let videos: [Video]?
    let publishDate, author: String?
    let authors: [String]?
    let language: String?

    enum CodingKeys: String, CodingKey {
        case title, text, url, video, videos
        case publishDate = "publish_date"
        case author, authors, language
    }
}

//struct Image: Codable {
//    let title: String?
//    let url: String?
//    let width, height: Int?
//}

struct Video: Codable {
    let title: String?
    let url: String?
    let summary: String?
    let duration: Int?
    let thumbnail: String?
}
