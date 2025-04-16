import Combine
import SwiftUI

private enum FocusableField: Hashable {
    case email
    case password
    case confirmPassword
}

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    @FocusState private var focus: FocusableField?

    private func signUpWithEmailPassword() {
        Task {
            if await viewModel.signUpWithEmailPassword() == true {
                dismiss()
            }
        }
    }

    var body: some View {
        VStack {
            Image(systemName: "newspaper")
                .resizable()
                .frame(width: 150, height: 150)
                .padding([.top, .bottom], 30)
            Text("Đăng Ký")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Image(systemName: "at")
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 4)

            HStack {
                Image(systemName: "lock")
                SecureField("Mật khẩu", text: $viewModel.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .confirmPassword
                    }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)

            HStack {
                Image(systemName: "lock")
                SecureField(
                    "Nhập lại mật khẩu", text: $viewModel.confirmPassword
                )
                .focused($focus, equals: .confirmPassword)
                .submitLabel(.go)
                .onSubmit {
                    signUpWithEmailPassword()
                }
            }
            .padding(.vertical, 6)
            .background(Divider(), alignment: .bottom)
            .padding(.bottom, 8)

            if !viewModel.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }

            Button(action: signUpWithEmailPassword) {
                if viewModel.authenticationState != .authenticating {
                    Text("Đăng ký")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!viewModel.isValid)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
            
            Spacer()

            HStack {
                Text("Bạn đã có tài khoản?")
                Button(action: { viewModel.switchFlow() }) {
                    Text("Đăng nhập")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }

        }
        .listStyle(.plain)
        .padding()
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignupView()
            SignupView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}
