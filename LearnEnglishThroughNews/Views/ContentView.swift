import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AuthenticationViewModel()
    @State var selectedTab: Int = 0
    @State var savedWords: [SavedWord] = []
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NewsView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Tin tức")
                }
                .tag(0)

            VocabView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Từ đã lưu")
                }
                .tag(1)

            QuizView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Ôn tập")
                }
                .tag(2)
            
            StatisticalView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg.rectangle")
                    Text("Thống Kê")
                }.tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Tài khoản")
                }
                .tag(4)
                .environmentObject(viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
