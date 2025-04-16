import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State var confirmResetPassword = false
    @State var confirmLogout = false
    @State var confirmAccountDeletion = false
    @State private var showingAlert = false
    
    private func resetPassword() {
        guard !viewModel.displayName.isEmpty else {
            return
        }
        
        Task {
            do {
                try await viewModel.resetPassword(email: viewModel.displayName)
                signOut()
            } catch {
                print("Lỗi khi gửi email: \(error.localizedDescription)")
            }
        }
    }

    private func deleteAccount() {
        Task {
            if await viewModel.deleteAccount() == true {
                dismiss()
            }
        }
    }

    private func signOut() {
        viewModel.signOut()
    }

    var body: some View {
        Form {
            Section {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .clipped()
                            .padding(4)
                            .overlay(
                                Circle().stroke(Color.accentColor, lineWidth: 2)
                            )
                        Spacer()
                    }
                }
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            
            Section("Email") {
                Text(viewModel.displayName)
            }
            
            Section {
                Button {
                    confirmResetPassword.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Text("Đặt lại mật khẩu")
                        Spacer()
                    }
                }
            }
            
            Section {
                Button {
                    confirmLogout.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Text("Đăng Xuất")
                        Spacer()
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    confirmAccountDeletion.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Text("Xoá Tài Khoản")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Tài Khoản")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Bạn có muốn đặt lại mật khẩu không?",
            isPresented: $confirmResetPassword,
            titleVisibility: .visible
        ) {
            Button("Đặt lại mật khẩu") {
                resetPassword()
                showingAlert = true
            }
            Button("Huỷ", role: .cancel) {}
        }
        .confirmationDialog(
            "Bạn có muốn đăng xuất không?",
            isPresented: $confirmLogout,
            titleVisibility: .visible
        ) {
            Button("Đăng Xuất") {
                signOut()
            }
            Button("Huỷ", role: .cancel) {}
        }
        .confirmationDialog(
            """
            Điều này sẽ xóa tài khoản của bạn vĩnh viễn.
            Bạn có muốn xóa tài khoản của mình không?
            """,
            isPresented: $confirmAccountDeletion,
            titleVisibility: .visible
        ) {
            Button("Xoá Tài Khoản", role: .destructive) {
                deleteAccount()
            }
            Button("Huỷ", role: .cancel) {}
        }
        .alert("Vui lòng truy cập đường dẫn được gửi trong email để đặt lại mật khẩu!", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(AuthenticationViewModel())
        }
    }
}
