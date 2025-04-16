//
//  StatisticalView.swift
//  LearnEnglishThroughNews
//
//  Created by Dũng on 29/3/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct StatisticalView: View {
    @State private var totalSavedWords: Int = 0
    @State private var wrongWords: [(word: String, meaning: String, count: Int)] = []
    let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Thống Kê")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack {
                StatCard(title: "Số từ đã lưu", value: totalSavedWords)
                StatCard(title: "Số lần làm sai", value: wrongWords.reduce(0) { $0 + $1.count })
            }
            .padding()
            
            if !wrongWords.isEmpty {
                Text("Từ vựng bị chọn sai")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                
                List(wrongWords, id: \.word) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.word)
                                .font(.headline)
                            Text(item.meaning)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("\(item.count) lần")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }
            } else {
                Text("Chưa có từ nào bị chọn sai.")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .onAppear {
            fetchStats()
        }
    }
    
    func fetchStats() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let wordsRef = db.collection("ql_tuvung").document(currentUser.uid).collection(currentUser.uid)
        wordsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Lỗi khi lấy dữ liệu từ vựng: \(error.localizedDescription)")
                return
            }
            self.totalSavedWords = snapshot?.documents.count ?? 0
        }
        
        let wrongAnswersRef = db.collection("ql_tuvung").document(currentUser.uid).collection("wrong_answers")
        wrongAnswersRef.getDocuments { snapshot, error in
            if let error = error {
                print("Lỗi khi lấy dữ liệu sai: \(error.localizedDescription)")
                return
            }
            
            var wordsList: [(word: String, meaning: String, count: Int)] = []
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                if let word = document.documentID as String?,
                   let meaning = data["nghia"] as? String,
                   let count = data["count"] as? Int {
                    wordsList.append((word, meaning, count))
                }
            }
            
            self.wrongWords = wordsList.sorted { $0.count > $1.count }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(value)")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
        }
        .frame(width: 150, height: 100)
        .background(Color.blue)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

//#Preview {
//    StatisticalView()
//}
