import SwiftUI

// UIViewRepresentable để hiển thị UITextView trong SwiftUI
struct CustomWordView: UIViewRepresentable {
    let text: String
    var onWordTap: (String) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false // văn bản tự động xuống dòng
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .natural
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isSelectable = false
        textView.delegate = context.coordinator

        // đảm bảo UITextView tuân theo layout của SwiftUI
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width - 40).isActive = true

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        textView.addGestureRecognizer(tapGesture)

        return textView
    }
    

    func updateUIView(_ uiView: UITextView, context: Context) {
        let attributedText = NSMutableAttributedString(string: text)
        let words = text.split(separator: " ")

        var location = 0
        for word in words {
            let range = NSRange(location: location, length: word.count)
            let attributes: [NSAttributedString.Key: Any] = [:]
            attributedText.addAttributes(attributes, range: range)
            location += word.count + 1 // +1 để tính khoảng trắng
        }

        uiView.attributedText = attributedText
        uiView.font = UIFont.systemFont(ofSize: 18)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Hàm xử lý sự kiện bấm vào từ
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomWordView

        init(_ parent: CustomWordView) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let textView = gesture.view as? UITextView else { return }
            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer
            let textStorage = textView.textStorage
            var location = gesture.location(in: textView)

            // Điều chỉnh vị trí touch dựa trên insets
            location.x -= textView.textContainerInset.left
            location.y -= textView.textContainerInset.top

            // Tìm vị trí ký tự trong văn bản
            let characterIndex = layoutManager.characterIndex(
                for: location,
                in: textContainer,
                fractionOfDistanceBetweenInsertionPoints: nil
            )

            // Kiểm tra nếu bấm ra ngoài phạm vi văn bản
            if characterIndex >= textStorage.length {
                return
            }

            // Xác định vị trí chính xác của ký tự để kiểm tra xem touch có nằm trên chữ không
            var glyphRange = NSRange()
            layoutManager.characterRange(forGlyphRange: NSRange(location: characterIndex, length: 1), actualGlyphRange: &glyphRange)

            var glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            glyphRect.origin.x += textView.textContainerInset.left
            glyphRect.origin.y += textView.textContainerInset.top

            // Nếu tọa độ bấm nằm ngoài chữ, không chọn từ
            if !glyphRect.contains(location) {
                return
            }

            // Lấy đúng từ được bấm, loại bỏ dấu câu (ngoại trừ '-')
            let textNSString = textView.text as NSString
            let wordRange = textNSString.rangeOfWord(at: characterIndex)

            if wordRange.location != NSNotFound {
                var tappedWord = textNSString.substring(with: wordRange).trimmingCharacters(in: .whitespacesAndNewlines)

                // Xóa tất cả dấu câu **ngoại trừ dấu '-**
                let allowedChars = CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "-"))
                tappedWord = tappedWord.filter { char in
                    char.unicodeScalars.allSatisfy { allowedChars.contains($0) }
                }

                if !tappedWord.isEmpty {
                    parent.onWordTap(tappedWord) // Gửi từ đã nhấn về SwiftUI
                }
            }
        }
    }
}

// Hàm mở rộng NSString để tìm đúng từ mà không dính dấu câu
extension NSString {
    func rangeOfWord(at index: Int) -> NSRange {
        let allowedCharacters = CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "-")) // Chỉ lấy chữ, số và "-"
        
        // Tìm vị trí bắt đầu của từ
        var start = index
        while start > 0, let scalar = UnicodeScalar(character(at: start - 1)), allowedCharacters.contains(scalar) {
            start -= 1
        }

        // Tìm vị trí kết thúc của từ
        var end = index
        while end < length, let scalar = UnicodeScalar(character(at: end)), allowedCharacters.contains(scalar) {
            end += 1
        }

        return NSRange(location: start, length: end - start)
    }
}

//#Preview {
//    CustomWordView()
//}
