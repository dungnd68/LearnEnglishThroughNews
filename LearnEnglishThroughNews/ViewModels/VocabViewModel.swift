import Foundation
import FirebaseFirestore
import FirebaseAuth

class VocabViewModel: ObservableObject {
    @Published var savedWords: [SavedWord] = []
    
    let db = Firestore.firestore()
    
    func fetchSavedWords() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Chưa có người dùng đăng nhập.")
            return
        }
        
        db.collection("ql_tuvung").document(currentUser.uid).collection(currentUser.uid)
            .order(by: "created_at", descending: true)
        // nghe thay đổi dữ liệu firestore theo thời gian thực
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Lỗi khi lấy dữ liệu: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("Không có từ nào trong Firestore.")
                    self.savedWords = [] // xóa danh sách hiện tại nếu không có từ nào
                    return
                }
                
                // chuyển dữ liệu firestore thành danh sách SavedWord
                self.savedWords = documents.compactMap { doc -> SavedWord? in
                    try? doc.data(as: SavedWord.self)
                }
            }
    }
    
    func deleteWords(_ word: SavedWord) {
        guard let currentUser = Auth.auth().currentUser else {
            print("Chưa có người dùng đăng nhập.")
            return
        }

        db.collection("ql_tuvung").document(currentUser.uid).collection(currentUser.uid).document(word.id ?? "")
            .delete { error in
                if let error = error {
                    print("Lỗi khi xóa từ: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.savedWords.removeAll { $0.id == word.id }
                    }
                }
            }
    }
}
