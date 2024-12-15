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

// MARK: - ContentView
struct ContentView: View {
    // MARK: - Properties
    @State private var flashcards: [Flashcard] = [
        Flashcard(
            statement: "È davvero affascinante che tu venga dal nord Italia, una regione ricca di storia, tradizioni e paesaggi mozzafiato. Mia nonna, ad esempio, viene da Cismon del Grappa e ogni estate trascorrevo lì, immergendomi nella cultura locale e apprezzando la bellezza delle montagne circostanti.",
            statementEmojis: ["🤩", "👉", "🌍", "🇮🇹", "📜", "🎎", "🌄", "👵", "📍", "☀️", "🏡", "🌐", "❤️", "🏔️"],
            question: "Sei già stato in quella zona prima d'ora? Qual è il nome della tua città natale e cosa ti piace di più di quel luogo?",
            questionEmojis: ["❓", "🚶‍♂️", "📍", "🕰️", "🏠", "❤️", "📍"]
        ),
        Flashcard(
            statement: "Quando ero al liceo, mi incuriosiva molto il fatto che l'Italia fosse un tempo divisa in numerosi stati e regni indipendenti, ognuno con i propri dialetti e culture uniche. Questa frammentazione ha sicuramente contribuito alla varietà linguistica e culturale che si osserva oggi in diverse regioni.",
            statementEmojis: ["⏳", "🏫", "🧑‍🎓", "🔍", "🇮🇹", "⏰", "✂️", "🌐", "🏰", "🗣️", "🌍", "📚", "🔄", "🗣️", "🌍"],
            question: "I dialetti sono davvero distinti? Quali ti sembrano i più strani e in che modo influenzano la comunicazione quotidiana?",
            questionEmojis: ["❓", "🗣️", "🔍", "🤨", "⚙️", "💬", "📅"]
        ),
        // ... (Add all other flashcards here in the same format)
        Flashcard(
            statement: "Mi interesso molto delle tradizioni culinarie regionali italiane, come la cucina piemontese o quella siciliana. Ogni regione ha i suoi ingredienti e piatti tipici che riflettono la storia e la geografia della zona, creando sapori unici e distintivi.",
            statementEmojis: ["❤️", "🔍", "🍲", "🍝", "🇮🇹", "📍", "🥫", "🍅", "📜", "📍", "🍲", "✨", "🔑", "🔍"],
            question: "Qual è la tua cucina regionale preferita e perché? Hai mai provato a cucinare qualche piatto tradizionale di quella regione?",
            questionEmojis: ["❓", "🍽️", "❤️", "🔍", "👨‍🍳", "🔪", "📜", "🍲", "📍"]
        )
        // Add all remaining flashcards similarly...
    ]
    
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
                            
                            Text(flashcards[currentCardIndex].question)
                                .font(.subheadline)
                                .padding([.leading, .trailing, .bottom])
                        }
                        
                        // Play Button
                        Button(action: {
                            playText(text: flashcards[currentCardIndex].statement + " " + flashcards[currentCardIndex].question)
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
                            HStack {
                                ForEach(flashcards[currentCardIndex].statementEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.largeTitle)
                                }
                            }
                            .padding()
                            
                            HStack {
                                ForEach(flashcards[currentCardIndex].questionEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.largeTitle)
                                }
                            }
                            .padding()
                        }
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
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
