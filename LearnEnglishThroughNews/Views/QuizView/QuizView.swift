//
//  QuizView.swift
//  HocTiengAnhQuaTinTuc
//
//  Created by Dũng on 04/01/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct QuizView: View {
    @State private var savedWords: [SavedWord] = []
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: FlashcardView(savedWords: savedWords)) {
                    Text("Thẻ ghi nhớ từ vựng")
                        .padding(.vertical, 10)
                }
                NavigationLink(destination: MultipleChoiceView(savedWords: savedWords)) {
                    Text("Trắc nghiệm từ vựng")
                        .padding(.vertical, 10)
                }
            }
            .navigationTitle("Ôn tập")
            .onAppear {
                fetchWords()
            }
        }
    }
    
    func fetchWords() {
        guard let currentUser = Auth.auth().currentUser else { return }
        db.collection("ql_tuvung").document(currentUser.uid).collection(currentUser.uid)
            .order(by: "created_at", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Lỗi khi tải dữ liệu: \(error)")
                    return
                }
                self.savedWords = snapshot?.documents.compactMap { doc -> SavedWord? in
                    let data = doc.data()
                    guard let word = data["tu_vung"] as? String,
                          let meaning = data["nghia"] as? String else { return nil }
                    return SavedWord(tu_vung: word, nghia: meaning)
                } ?? []
            }
    }
}

//struct QuizView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuizView()
//    }
//}
