import Firebase
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct LearnEnglishThroughNewsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AuthenticatedView {
                VStack(alignment: .leading) {
                    Spacer()
                    Image(systemName: "newspaper")
                        .resizable()
                        .frame(width: 110, height: 110)
                    Text("Welcome to")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                    Text("""
                        Learn English
                        Through News
                        """)
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                    Spacer()
                    Spacer()
                }
            } content: {
                ContentView()
            }
        }
    }
}
