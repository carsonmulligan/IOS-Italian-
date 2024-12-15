import SwiftUI
import AVFoundation

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
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(radius: 5)
                        .padding()
                    
                    VStack(spacing: 20) {
                        ScrollView {
                            Text(flashcards[currentCardIndex].statement)
                                .font(.headline)
                                .padding()
                            
                            HStack {
                                ForEach(flashcards[currentCardIndex].statementEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.largeTitle)
                                }
                            }
                            .padding()
                        }
                        
                        // Play Button
                        Button(action: {
                            playText(text: flashcards[currentCardIndex].statement)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                        }
                        .padding(.bottom, 20)
                    }
                }
                // Back Side
                else {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.yellow.opacity(0.3))
                        .shadow(radius: 5)
                        .padding()
                    
                    VStack(spacing: 20) {
                        ScrollView {
                            Text(flashcards[currentCardIndex].question)
                                .font(.headline)
                                .padding()
                            
                            HStack {
                                ForEach(flashcards[currentCardIndex].questionEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.largeTitle)
                                }
                            }
                            .padding()
                        }
                        
                        // Play Button
                        Button(action: {
                            playText(text: flashcards[currentCardIndex].question)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.6)
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
                        Image(systemName: "chevron.left.circle.fill")
                        Text("Previous")
                    }
                    .padding()
                    .foregroundColor(currentCardIndex > 0 ? .blue : .gray)
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
                        Image(systemName: "chevron.right.circle.fill")
                    }
                    .padding()
                    .foregroundColor(currentCardIndex < flashcards.count - 1 ? .blue : .gray)
                }
                .disabled(currentCardIndex == flashcards.count - 1)
            }
            .padding([.leading, .trailing], 40)
        }
        .background(Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all))
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
