import SwiftUI

struct NewsView: View {
    @StateObject var newsViewModel = NewsViewModel()
    @StateObject var newsContentViewModel = NewsContentViewModel()
    @State private var searchArticle = ""
    
    var filteredArticles: [Article] {
        if searchArticle.isEmpty {
            return newsViewModel.articles
        } else {
            return newsViewModel.articles.filter {
                $0.title.localizedCaseInsensitiveContains(searchArticle)
            }
        }
    }
        
    var body: some View {
        NavigationStack {
            if newsViewModel.isLoading {
                ProgressView()
            } else {
                List(filteredArticles, id: \.url) { article in
                    ZStack {
                        NewsRowView(article: article)
                        NavigationLink(destination: NewsContentView(article: article)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                }
                .refreshable {
                    newsViewModel.fetchNews()
                }
                .navigationTitle("Tin Tức")
                .searchable(text: $searchArticle, prompt: "Tìm kiếm bài báo")
            }
        }
    }
}

struct NewsRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 320, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    ProgressView()
                }
            }
            Text(article.title)
                .font(.headline)
                .lineLimit(5)
            Text(article.source.name)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}
