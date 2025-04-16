
// viewbuilder https://michael-ginn.medium.com/creating-optional-viewbuilder-parameters-in-swiftui-views-a0d4e3e1a0ae


import SwiftUI

extension AuthenticatedView where Unauthenticated == EmptyView {
    // khởi tạo AuthenticatedView mà kh cần truyền vào Unauthenticated
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View
where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var loginScreen = false

    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content

    public init(
        unauthenticated: Unauthenticated?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.unauthenticated = unauthenticated
        self.content = content
    }

    public init(
        @ViewBuilder unauthenticated: @escaping () -> Unauthenticated,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.unauthenticated = unauthenticated()
        self.content = content
    }

    var body: some View {
        switch viewModel.authenticationState {
        case .unauthenticated, .authenticating:
            VStack {
                if let unauthenticated {
                    unauthenticated
                } else {
                    Text("Bạn chưa đăng nhập.")
                }
                Button("Đăng nhập để tiếp tục") {
                    viewModel.reset()
                    loginScreen.toggle()
                }
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                Spacer()
            }
            .sheet(isPresented: $loginScreen) {
                AuthenticationView()
                    .environmentObject(viewModel)
            }
        case .authenticated:
            content()
        }
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView {
            Text("Bạn đã đăng nhập.")
                .frame(
                    maxWidth: .infinity, maxHeight: .infinity,
                    alignment: .center
                )
                .background(.yellow)
        }
    }
}
