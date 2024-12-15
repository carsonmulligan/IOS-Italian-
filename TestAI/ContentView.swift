import SwiftUI
import AVFoundation

// MARK: - Custom Colors
struct CustomColors {
    static let background = Color(hex: "1C1C1E")  // Dark background like Claude
    static let cardFront = Color(hex: "2C2C2E")   // Slightly lighter gray for cards
    static let cardBack = Color(hex: "7D5260")    // Purple tint for back of cards
    static let accent = Color(hex: "E17059")      // Claude's orange accent
    static let text = Color.white.opacity(0.87)   // White text with slight transparency
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Flashcard Model
struct Flashcard: Identifiable {
    let id = UUID()
    let statement: String
    let statementEmojis: [String]
    let question: String
    let questionEmojis: [String]
}

// Add this struct to conform to Codable
struct FlashcardData: Codable {
    let statement: String
    let statement_emojis: [String]
    let question: String
    let question_emojis: [String]
}

// MARK: - ContentView
struct ContentView: View {
    // MARK: - Properties
    @State private var flashcards: [Flashcard] = []
    @State private var currentCardIndex: Int = 0
    @State private var isFlipped: Bool = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Body
    var body: some View {
        VStack {
            Spacer()
            
            // Flashcard View
            ZStack {
                // Front Side
                if !isFlipped {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(CustomColors.cardFront)
                        .shadow(radius: 10)
                    
                    VStack(spacing: 24) {
                        ScrollView {
                            Text(flashcards[currentCardIndex].statement)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(CustomColors.text)
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 12) {
                                ForEach(flashcards[currentCardIndex].statementEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        
                        Button(action: {
                            playText(text: flashcards[currentCardIndex].statement)
                        }) {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 24))
                                .foregroundColor(CustomColors.accent)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(CustomColors.cardFront)
                                        .shadow(radius: 5)
                                )
                        }
                        .padding(.bottom, 16)
                    }
                }
                // Back Side
                else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(CustomColors.cardBack)
                        .shadow(radius: 10)
                    
                    VStack(spacing: 24) {
                        ScrollView {
                            Text(flashcards[currentCardIndex].question)
                                .font(.system(size: 20, weight: .regular))
                                .foregroundColor(CustomColors.text)
                                .padding(.horizontal, 24)
                                .padding(.top, 24)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 12) {
                                ForEach(flashcards[currentCardIndex].questionEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        
                        Button(action: {
                            playText(text: flashcards[currentCardIndex].question)
                        }) {
                            Image(systemName: "speaker.wave.2")
                                .font(.system(size: 24))
                                .foregroundColor(CustomColors.accent)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(CustomColors.cardBack)
                                        .shadow(radius: 5)
                                )
                        }
                        .padding(.bottom, 16)
                    }
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.6)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
            .onTapGesture {
                withAnimation {
                    isFlipped.toggle()
                }
            }
            
            Spacer()
            
            // Navigation Buttons
            HStack {
                Button(action: {
                    if currentCardIndex > 0 {
                        currentCardIndex -= 1
                        isFlipped = false
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .foregroundColor(currentCardIndex > 0 ? CustomColors.accent : CustomColors.text.opacity(0.3))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(CustomColors.cardFront)
                            .shadow(radius: 5)
                    )
                }
                .disabled(currentCardIndex == 0)
                
                Spacer()
                
                Button(action: {
                    if currentCardIndex < flashcards.count - 1 {
                        currentCardIndex += 1
                        isFlipped = false
                    }
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(currentCardIndex < flashcards.count - 1 ? CustomColors.accent : CustomColors.text.opacity(0.3))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(CustomColors.cardFront)
                            .shadow(radius: 5)
                    )
                }
                .disabled(currentCardIndex == flashcards.count - 1)
            }
            .padding(.horizontal, 24)
        }
        .background(CustomColors.background.edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Functions
    private func playText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "it-IT")
        speechSynthesizer.speak(utterance)
    }
    
    // Add this extension to load flashcards from JSON
    private func loadFlashcards() -> [Flashcard] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let flashcardData = try? JSONDecoder().decode([FlashcardData].self, from: data) else {
            return []
        }
        
        return flashcardData.map { data in
            Flashcard(
                statement: data.statement,
                statementEmojis: data.statement_emojis,
                question: data.question,
                questionEmojis: data.question_emojis
            )
        }
    }
    
    // Add this to your ContentView
    init() {
        _flashcards = State(initialValue: loadFlashcards())
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
