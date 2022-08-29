//
//  ContentView.swift
//  Travel KZH
//
//  Created by Julien Widmer on 2022-07-05.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            // MARK: - NavigationView - Currency
            NavigationView {
                CurrencyView()
            }
            .tabItem {
                Image(systemName: "tengesign.square")
                Text("Currency")
            }
            // MARK: - NavigationView - Vocabulary
            NavigationView {
                Form {
                    Section {
                        let glossary: [Glossary] = [.greetings, .conversations, .dining, .food, .weather]
                        
                        List(glossary, children: \.terms) { term in
                            
                            if let englishTranslation = term.englishTranslation {
                                HStack {
                                    Text(englishTranslation)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .font(Font.system(size: 16, design: .default))
                                    
                                    Spacer()
                                    Text(term.russianTranslation!)
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        .font(Font.system(size: 16, design: .monospaced))
                                }
                            } else {
                                Image(systemName: term.icon)
                                Text(term.categoryName)
                            }
                            
                        }
                    } header: {
                        Text("Basic words and sentences")
                    }
                }
                .navigationTitle("Kazakhstan 🇰🇿")
            }
            .tabItem {
                Image(systemName: "person.2.wave.2.fill")
                Text("Vocabulary")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
