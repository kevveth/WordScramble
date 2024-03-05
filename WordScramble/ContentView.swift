//
//  ContentView.swift
//  WordScramble
//
//  Created by Kenneth Oliver Rathbun on 3/2/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var usedWords: [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack {
            List {
                // Enter a new word
                Section {
                    TextField("Enter a new word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                // Display used words
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
        }
        .onSubmit(addNewWord)
        .onAppear(perform: startGame)
        .alert(errorTitle, isPresented: $showingError) {
            //            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func addNewWord() {
        // lowercase, trim the word and filter whitespaces, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .newlines).filter { !$0.isWhitespace }
        print(answer)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        // extra validation to come
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from \(rootWord)!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard !isShort(word: answer) else {
            wordError(title: "Word is too short", message: "Add some more letters")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Start word repeated", message: "You can't use the word we started with!")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        // Find the URL for start.txt in the app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            // Load the contents of start.txt into a String
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Split the string up into an array of strings, splitting on linebreaks
                let allWords = startWords.components(separatedBy: .newlines)
                
                // Pick a random word, or use a sensible default
                rootWord = allWords.randomElement() ?? "pineapple"
                
                // If this point is reached, everything was successful
                return
            }
        }
        
        // If this point is reached then there was a problem - trigger a crash and report the problem
        fatalError("Could not load start.txt from bundle.")
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
        
        // If the word was OK the location for that range will be the special value NSNotFound
        return misspelledRange.location == NSNotFound
    }
    
    func isShort(word: String) -> Bool {
        word.count < 3
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
