//
//  ContentView.swift
//  WordScramble
//
//  Created by Uriel Ortega on 19/04/23.
//

import SwiftUI

struct ContentView: View {
    @State private var score = 0

    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar {
                Button("New word") {
                    startGame()
                }
            }
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {  }
            } message: {
                Text(errorMessage)
            }
            .safeAreaInset(edge: .bottom) {
                ScoreBoard(value: score)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return } // exit if the remaining string is empty
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return // exit if the word isn't original
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return // exit if the word isn't possible
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return // exit if the word isn't real
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too short", message: "Try with a longer word")
            return // exit if the word isn't long enough
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            updateScore(with: answer)
        }
        newWord = ""
    }
    
    func startGame() {
        withAnimation {
            usedWords.removeAll()
        }
        newWord = ""
        score = 0

        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func updateScore(with word: String) {
        let bonus = usedWords.count
        score += word.count + bonus
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        return word.count > 3
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ScoreBoard: View {
    var value: Int
    
    var body: some View {
        Text("Score: \(value)")
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(20)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.20), radius: 25)
    }
}
