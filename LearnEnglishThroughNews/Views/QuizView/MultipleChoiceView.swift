
// sound effects https://www.youtube.com/watch?v=iBLZ1C4L5Mw&t=354s

import SwiftUI
import AVFoundation
import FirebaseAuth
import FirebaseFirestore

struct MultipleChoiceView: View {
    @State private var currentIndex = 0
    @State private var options: [String] = []
    @State private var correctAnswer = ""
    @State private var selectedAnswer: String? = nil
    @State private var isAnswered = false
    @State private var message = ""
    @State private var audioPlayer: AVAudioPlayer?

    var savedWords: [SavedWord]
    let db = Firestore.firestore()
    
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if savedWords.count < 4 {
                Text("Hãy lưu 4 từ trở lên")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Text("Chọn nghĩa đúng")
                    .font(.title2)

                HStack {
                    Text(savedWords[currentIndex].tu_vung)
                        .font(.largeTitle)
                        .bold()
                        .padding(.vertical, 30)
                    
                    Button(action: {
                        speakText(text: savedWords[currentIndex].tu_vung)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                    }
                }

                ForEach(options, id: \.self) { option in
                    Button {
                        if !isAnswered {
                            checkAnswer(option)
                        }
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 70)
                            .background(buttonColor(for: option))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            .shadow(radius: 5)
                    }
                    .disabled(isAnswered)
                }

                if isAnswered {
                    Text(message)
                        .font(.headline)
                        .padding()

                    Button("Tiếp tục") {
                        nextQuestion()
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .padding()
        .onAppear {
            loadQuestion()
        }
    }

    func loadQuestion() {
        guard savedWords.count >= 4 else { return }

        isAnswered = false
        message = ""
        selectedAnswer = nil

        let currentWord = savedWords[currentIndex]
        correctAnswer = currentWord.nghia

        let incorrectAnswers = savedWords
            .filter { $0.tu_vung != currentWord.tu_vung } // loại bỏ từ đang hỏi
            .shuffled()
            .prefix(3) // chọn 3 từ sai

        options = ([correctAnswer] + incorrectAnswers.map { $0.nghia }).shuffled()
    }
    
    func checkAnswer(_ selected: String) {
        selectedAnswer = selected
        isAnswered = true
        if selected == correctAnswer {
            message = "✅ Chính xác! 👏"
            playCustomSound(isCorrect: true)
        } else {
            message = "❌ Sai! 😭 Đáp án đúng: \(correctAnswer)"
            playCustomSound(isCorrect: false)
            updateWrongAnswer(for: savedWords[currentIndex])
        }
    }

    func updateWrongAnswer(for word: SavedWord) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let wordRef = db.collection("ql_tuvung").document(currentUser.uid).collection("wrong_answers").document(word.tu_vung)
        
        wordRef.getDocument { document, error in
            if let error = error {
                print("Lỗi khi lấy dữ liệu từ Firestore: \(error.localizedDescription)")
                return
            }
            
            if let data = document?.data(), let count = data["count"] as? Int {
                // đã sai +1 số lần sai
                wordRef.updateData(["count": count + 1])
            } else {
                // chưa có: thêm vào, +1 số lượng
                wordRef.setData(["count": 1, "nghia": word.nghia])
            }
        }
    }

    func nextQuestion() {
        if currentIndex < savedWords.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        loadQuestion()
    }

    func buttonColor(for option: String) -> Color {
        if isAnswered {
            if option == correctAnswer {
                return Color.green
            } else if option == selectedAnswer {
                return Color.red
            }
        }
        return Color.white
    }
    
    private func speakText(text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en_US")
        speechSynthesizer.speak(utterance)
    }
    
    func playCustomSound(isCorrect: Bool) {
        let soundName = isCorrect ? "correct" : "incorrect"
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Không thể phát âm thanh: \(error.localizedDescription)")
            }
        } else {
            print("Không tìm thấy file âm thanh \(soundName).mp3")
        }
    }
}

//#Preview {
//    MultipleChoiceView()
//}
