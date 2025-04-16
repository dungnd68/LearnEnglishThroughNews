import SwiftUI
import AVFoundation

struct FlashcardView: View {
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var slideDirection: Edge = .trailing
    
    var savedWords: [SavedWord]
    
    var body: some View {
        VStack {
            if savedWords.isEmpty {
                Text("Chưa có từ nào được lưu.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                VStack {
                    Text("Thẻ Ghi Nhớ")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 100)
                        .padding(.top, 20)

                    ZStack {
                        ForEach(savedWords.indices, id: \..self) { index in
                            if index == currentIndex {
                                Flashcard(isFlipped: $isFlipped, word: savedWords[index])
                                    .transition(.asymmetric(insertion: .move(edge: slideDirection),
                                                            removal: .move(edge: slideDirection == .leading ? .trailing : .leading)))
                            }
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -100 {
                                    slideDirection = .trailing
                                    nextCard()
                                } else if value.translation.width > 100 {
                                    slideDirection = .leading
                                    previousCard()
                                }
                            }
                    )
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    func nextCard() {
        withAnimation(.easeInOut) {
            isFlipped = false
            if currentIndex < savedWords.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }
    
    func previousCard() {
        withAnimation(.easeInOut) {
            isFlipped = false
            if currentIndex > 0 {
                currentIndex -= 1
            } else {
                currentIndex = savedWords.count - 1
            }
        }
    }
}

struct Flashcard: View {
    @Binding var isFlipped: Bool
    
    let word: SavedWord
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            ZStack {
                if !isFlipped {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(width: 300, height: 200)
                        .shadow(radius: 5)
                        .overlay(
                            Text(word.tu_vung)
                                .font(.title)
                                .foregroundColor(.black)
                                .bold()
                                .multilineTextAlignment(.center)
                        )
                        
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue)
                        .frame(width: 300, height: 200)
                        .shadow(radius: 5)
                        .overlay(
                            Text(word.nghia)
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                                .multilineTextAlignment(.center)
                        )
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        
                }
            }
            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .onTapGesture {
                withAnimation {
                    isFlipped.toggle()
                }
            }
            
            Button(action: {
                speakText(text: isFlipped ? word.nghia : word.tu_vung)
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.top, 50)
        }
    }
    
    private func speakText(text: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: isFlipped ? "vi-VN" : "en-US")
        speechSynthesizer.speak(utterance)
    }
}

//#Preview {
//    FlashcardView()
//}
