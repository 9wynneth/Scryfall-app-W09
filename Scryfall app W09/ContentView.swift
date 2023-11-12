import SwiftUI



struct Card: Identifiable, Codable {
    let id = UUID()
    let name: String
    let image_uris: CardImageUris
    let legalities: Legalities
    let mana_cost: String
    let type_line: String
    let oracle_text: String
    let rarity: String
    let artist: String
    let prices: Prices

        struct Prices: Codable {
            let usd: String
            let usd_foil: String
            let eur: String
            let eur_foil: String
        }
    
}

struct Legalities: Codable {
    let standard: String
    let future: String
    let historic: String
    let gladiator: String
    let pioneer: String
    let explorer: String
    let modern: String
    let legacy: String
    let pauper: String
    let vintage: String
    let penny: String
    let commander: String
    let oathbreaker: String
    let brawl: String
    let historicbrawl: String
    let alchemy: String
    let paupercommander: String
    let duel: String
    let oldschool: String
    let premodern: String
    let predh: String
}


struct CardImageUris: Codable {
    let small: String
    let art_crop: String
    let large: String
    let png: String
 
}

struct CardList: Codable {
    let data: [Card]
}

struct RemoteImage: View {
    let url: String

    var body: some View {
        if let imageURL = URL(string: url), let imageData = try? Data(contentsOf: imageURL), let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
        }
    }
}

struct StickyHeader<Content: View>: View {

    var minHeight: CGFloat
    var content: Content
    
    init(minHeight: CGFloat = 200, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            if(geo.frame(in: .global).minY <= 0) {
                content
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            } else {
                content
                    .offset(y: -geo.frame(in: .global).minY)
                    .frame(width: geo.size.width, height: geo.size.height + geo.frame(in: .global).minY)
            }
        }.frame(minHeight: minHeight)
    }
}

struct ManaCostView: View {
    let manaCost: String

    var body: some View {
        HStack(spacing: 5) {
            ForEach(manaCost.manaSymbols, id: \.self) { symbol in
                ZStack {
                    Circle()
                        .fill(circleColor(for: manaCost))
                        .frame(width: 30, height: 30)
                    Text(symbol)
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
    }

    func circleColor(for manaCost: String) -> Color {
        guard manaCost.count >= 2 else {
            return .white // Default color if manaCost is too short
        }

        let colorCode = manaCost[manaCost.index(manaCost.startIndex, offsetBy: 1)]
        switch colorCode {
        case "W":
            return .gray
        case "U":
            return .blue
        case "B":
            return .black
        case "R":
            return .red
        case "G":
            return .green
        default:
            return .gray
        }
    }
}

extension String {
    var manaSymbols: [String] {
        var symbols: [String] = []

        for character in self {
            switch character {
            case "W":
                symbols.append("")
            case "U":
                symbols.append("")
            case "B":
                symbols.append("")
            case "R":
                symbols.append("")
            case "G":
                symbols.append("")
            default:
                if let intValue = Int(String(character)) {
                    symbols.append("")
                }
            }
        }

        return symbols
    }
}

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPopupPresented: Bool

    var body: some View {
        Button(action: {
            self.isPopupPresented = false
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.white)
                .imageScale(.large)
                .frame(width: 30, height: 30)
                .opacity(isPopupPresented ? 0.5 : 1.0)
        }
    }
}

struct CardDetail: View {
    let card: Card
    @State private var isPopupPresented = false
    @State private var selectedTab: Tab = .version // Default selected tab
    
    enum Tab {
        case version
        case ruling
    }

    var legalitiesList: [String] {
        let mirror = Mirror(reflecting: card.legalities)
        return mirror.children.compactMap { label, value in
            guard let legality = value as? String else { return nil }
            return "\(label): \(legality)"
        }
    }

    var body: some View {
        ZStack {
            ScrollView {
                RemoteImage(url: card.image_uris.art_crop)
                    .aspectRatio(contentMode: .fill)
                    .frame(height: UIScreen.main.bounds.height / 4)
                    .edgesIgnoringSafeArea(.top)
                    .padding(.top, 0)
                    .offset(y: -70)
                    .onTapGesture {
                        isPopupPresented.toggle()
                    }

                HStack {
                    Text(card.name)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)

                    Spacer()
                    ManaCostView(manaCost: card.mana_cost)
                        .padding(5)
                }

                VStack(spacing: 5) {
                    Text(card.type_line)
                        .font(.headline)
                        .padding(5)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: -15)

                    Text(card.oracle_text)
                        .font(.body)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color.gray.opacity(0.1))
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                .padding(5)
                        )

                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.gray)
                            .padding(5)
                        Spacer()
                        Button(action: {
                        selectedTab = .version // Switch to "Version" tab
                        }) {
                        Text("Details")
                        .foregroundColor(selectedTab == .version ? .white : .black)
                        .padding()
                        .background(selectedTab == .version ? Color.orange : Color.white)
                        .cornerRadius(5)
                        .frame(maxWidth: 280, maxHeight: 50)
                        }
                        Spacer()

                        Button(action: {
                        selectedTab = .ruling // Switch to "Ruling" tab
                        }) {
                        Text("Ruling")
                                                                       .foregroundColor(selectedTab == .ruling ? .white : .gray)
                                                                       .padding()
                                                                       .background(selectedTab == .ruling ? Color.orange : Color.white)
                                                                       .border(Color.gray, width: 1)
                                                                       .cornerRadius(5)
                                                                       .frame(maxWidth: 280, maxHeight: 50)
                                                               }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .padding(5)
                    }
                    .padding(.top, 10)
                }

                VStack(alignment: .leading, spacing: 5) {
                    if selectedTab == .ruling {
                        ForEach(legalitiesList, id: \.self) { legality in
                            Text(legality)
                                .font(.title)
                                .background(legalityBackgroundColor)
                                .foregroundColor(legalityTextColor)
                        }
                    }
                    else if selectedTab == .version {
                        Text("Rarity: \(card.rarity)")
                        Text("Artist: \(card.artist)")
                        // Prices Section
//                        Section(header: Text("Prices")) {
//                            HStack {
//                                // Empty cell for layout
//                                Spacer()
//
//                                // Price headers
//                                Text("USD")
//                                    .bold()
//                                    .frame(maxWidth: .infinity)
//                                Text("EUR")
//                                    .bold()
//                                    .frame(maxWidth: .infinity)
//                            }
//
//                            // Normal Prices
//                            HStack {
//                                Text("Normal")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                Text(card.prices.usd)
//                                    .frame(maxWidth: .infinity)
//                                Text(card.prices.eur)
//                                    .frame(maxWidth: .infinity)
//                            }
//
//                            // Foil Prices
//                            HStack {
//                                Text("Foil")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                Text(card.prices.usd_foil)
//                                    .frame(maxWidth: .infinity)
//                                Text(card.prices.eur_foil)
//                                    .frame(maxWidth: .infinity)
//                            }
//                        }
//                        .padding(.top, 10)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton(isPopupPresented: $isPopupPresented))

            if isPopupPresented {
                Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPopupPresented.toggle()
                        }

                ZStack {
                    RemoteImage(url: card.image_uris.large)
                        .scaledToFit()
                        .frame(maxWidth: 300, maxHeight: UIScreen.main.bounds.height)
                        .onTapGesture {
                            isPopupPresented.toggle()
                        }

                    RoundedRectangle(cornerRadius: 25)
                        .foregroundColor(.white)
                        .overlay(
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)

                                Text("Download")
                                    .foregroundColor(.black)
                                    .font(.headline)
                                    .padding()
                            }
                        )
                        .frame(maxWidth: 200, maxHeight: 50)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.top, 500)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 10)
                        .alignmentGuide(.top) { d in d[.bottom] }
                        .onTapGesture {
                            if let url = URL(string: card.image_uris.png) {
                                    UIApplication.shared.open(url)
                                }
                        }

                }
                .transition(.opacity)
                .animation(.easeInOut)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }



    var legalityBackgroundColor: Color {
        return cardLegalities.standard == "legal" ? Color.green : (cardLegalities.standard == "banned" ? Color.red :  Color.gray)
    }

    var legalityTextColor: Color {
        return cardLegalities.standard == "legal" ? Color.white : Color.black
    }

    var cardLegalities: Legalities {
        return card.legalities
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

