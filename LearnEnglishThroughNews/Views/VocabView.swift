//
//  VocabView.swift
//  HocTiengAnhQuaTinTuc
//
//  Created by Dũng on 04/01/2025.
//

import SwiftUI
import AVFoundation

enum SortOrder {
    case aZ
    case zA
    case latest
}

struct VocabView: View {
    @StateObject var vocabViewModel = VocabViewModel()
    @State private var searchWords = ""
    @State private var sortOrder: SortOrder = .latest
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var filteredWords: [SavedWord] {
        let sortedWords: [SavedWord]

        switch sortOrder {
        case .aZ:
            sortedWords = vocabViewModel.savedWords.sorted { $0.tu_vung < $1.tu_vung }
        case .zA:
            sortedWords = vocabViewModel.savedWords.sorted { $0.tu_vung > $1.tu_vung }
        case .latest:
            sortedWords = vocabViewModel.savedWords
        }
        
        if searchWords.isEmpty {
            return sortedWords
        } else {
            return vocabViewModel.savedWords.filter {
                $0.tu_vung.hasPrefix(searchWords.lowercased()) ||
                $0.nghia.hasPrefix(searchWords.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if vocabViewModel.savedWords.isEmpty {
                Text("Chưa có từ nào được lưu.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(filteredWords) { word in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(word.tu_vung)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                Button(action: {
                                    speakText(text: word.tu_vung)
                                }) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.title2)
                                }
                            }
                            
                            Text(word.nghia)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(5)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vocabViewModel.deleteWords(word)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .navigationTitle("Từ đã lưu")
                .searchable(text: $searchWords, prompt: "Tìm từ vựng")
                .toolbar {
                    Menu {
                        Button("A-Z") { sortOrder = .aZ }
                        Button("Z-A") { sortOrder = .zA }
                        Button("Mới nhất") { sortOrder = .latest }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .onAppear {
            vocabViewModel.fetchSavedWords()
        }
    }
    
    private func speakText(text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en_US")
        speechSynthesizer.speak(utterance)
    }
}

struct VocabView_Previews: PreviewProvider {
    static var previews: some View {
        VocabView()
    }
}
