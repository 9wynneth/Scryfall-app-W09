import SwiftUI

struct Card: Identifiable, Codable {
    let id = UUID()
    let name: String
    let image_uris: CardImageUris
    let legalities: Legalities
    
}

struct Legalities: Codable {
    let standard: String
    let future: String
    let historic: String
}


struct CardImageUris: Codable {
    let small: String
}

struct CardList: Codable {
    let data: [Card]
}



struct CardDetail: View {
    let card: Card

    var legalitiesList: [String] {
        let mirror = Mirror(reflecting: card.legalities)
        return mirror.children.map { label, value in
            "\(label): \(value)"
        }
    }

    var legalityBackgroundColor: Color {
        return cardLegalities.standard == "legal" ? Color.green : (cardLegalities.standard == "banned" ? Color.red : Color.gray)
    }

    var legalityTextColor: Color {
        return cardLegalities.standard == "legal" ? Color.white : Color.black
    }

    var cardLegalities: Legalities {
        return card.legalities
    }

    var body: some View {
        VStack {
            RemoteImage(url: card.image_uris.small)
                .aspectRatio(contentMode: .fit)

            Text(card.name)
                .font(.title)
                .padding()
                .background(legalityBackgroundColor)
                .foregroundColor(legalityTextColor)
                .cornerRadius(10)
                .padding(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(legalityTextColor, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 5) {
                ForEach(legalitiesList, id: \.self) { legality in
                    Text(legality)
                        .font(.title)
                        .background(legalityBackgroundColor)
                        .foregroundColor(legalityTextColor)
                }
            }
        }
        .navigationTitle(card.name)
    }
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var searchText = ""
    @State private var currentSorting: CardSorting = .ascending

    enum CardSorting: String {
        case ascending = "A-Z"
        case descending = "Z-A"
    }

    var filteredCards: [Card] {
        if searchText.isEmpty {
            return cards
        } else {
            return cards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    TextField("Search Cards", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        currentSorting = currentSorting == .ascending ? .descending : .ascending
                        cards.sort { card1, card2 in
                            if currentSorting == .ascending {
                                return card1.name < card2.name
                            } else {
                                return card1.name > card2.name
                            }
                        }
                    }) {
                        Text("Sort \(currentSorting.rawValue)")
                    }
                    .padding()
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(filteredCards) { card in
                        NavigationLink(destination: CardDetail(card: card)) {
                            VStack {
                                RemoteImage(url: card.image_uris.small)
                                    .frame(width: 100, height: 150)
                                Text(card.name)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Magic Cards")
            .onAppear {
                if let url = Bundle.main.url(forResource: "WOT-Scryfall", withExtension: "json") {
                    do {
                        let data = try Data(contentsOf: url)
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(CardList.self, from: data)
                        cards = decodedData.data
                    } catch {
                        print("Error loading JSON data: \(error)")
                    }
                } else {
                    print("Failed to find the JSON file")
                }
            }
        }
    }
}

