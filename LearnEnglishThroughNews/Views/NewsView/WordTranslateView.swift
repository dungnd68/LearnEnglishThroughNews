import SwiftUI
import Translation
import FirebaseFirestore
import FirebaseAuth
import AVFoundation

struct WordTranslateView: View {
    @State private var targetText = ""
    @State private var showSheet: Bool = false
    @State private var selectedWord: String = ""
    @State private var showingAlert = false
    @State private var alert: String = ""
    @State private var configuration: TranslationSession.Configuration?

    let text: String
    let db = Firestore.firestore()
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        CustomWordView(text: text) { tappedWord in
            self.selectedWord = tappedWord
            triggerTranslation()
            self.showSheet = true
        }
        .translationTask(configuration) { session in
            do {
                selectedWord = selectedWord.lowercased()
                let response = try await session.translate(selectedWord)
                targetText = response.targetText.lowercased()
            } catch {
                // Handle any errors.
            }
        }
        .sheet(isPresented: $showSheet) {
            VStack {
                Rectangle()
                    .frame(width: 30, height: 5)
                    .foregroundStyle(.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 10)
                
                Text("Bản dịch")
                    .font(.headline)
                    .padding(.top, 10)
                
                Divider()
                    .frame(minHeight: 1)
                    .frame(maxWidth: 350)
                    .overlay(.blue)
                
                HStack {
                    Text(selectedWord)
                        .font(.title)
                    
                    Button(action: {
                        speakText(text: selectedWord)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                    }
                }
                
                Text(targetText.isEmpty ? "Đang dịch..." : targetText)
                    .font(.title3)
                    .padding()
                    .padding(.bottom, 20)
                
                Spacer()
                
                Button {
                    saveWord()
                    showSheet.toggle()
                } label: {
                    Text("Lưu")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .presentationDetents([.fraction(0.4)])
        }
        .alert(alert, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private func triggerTranslation() {
        if configuration == nil {
              configuration = .init(source: Locale.Language(identifier: "en_US"),
                                    target: Locale.Language(identifier: "vi_VN"))
          } else {
              configuration?.invalidate()
          }
    }
    
    private func saveWord() {
        guard let user = Auth.auth().currentUser else { return }
        
        let userCollection = db.collection("ql_tuvung").document(user.uid).collection(user.uid)
        
        // kiểm tra từ đã tồn tại chưa
        userCollection.whereField("tu_vung", isEqualTo: selectedWord).getDocuments { snapshot, error in
            if let error = error {
                print("Lỗi truy vấn Firestore: \(error.localizedDescription)")
                return
            }
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                alert = "❗️ Từ đã tồn tại!"
                showingAlert = true
            } else {
                alert = "✅ Đã lưu!"
                showingAlert = true
                
                let objWord: [String: Any] = [
                    "tu_vung": selectedWord,
                    "nghia": targetText,
                    "created_at": FieldValue.serverTimestamp(),
//                    "updated_at": "",
//                    "deleted_at": "",
                ]
                userCollection.addDocument(data: objWord)
            }
        }
    }
    
    private func speakText(text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en_US")
        speechSynthesizer.speak(utterance)
    }
}

//#Preview {
//    TextTranslateView()
//}
