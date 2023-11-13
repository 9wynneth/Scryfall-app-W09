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
    let prices: Prices?
    
}

struct Prices: Codable {
    let usd: String?
    let usd_foil: String?
    let eur: String?
    let eur_foil: String?
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
    
    var legalitiesList: [(String, String)] {
            let mirror = Mirror(reflecting: card.legalities)
            return mirror.children.compactMap { label, value in
                guard let legality = value as? String else { return nil }
                return (label ?? "", legality)
            }
    }
    
    func legalityBackgroundColor(for legality: String) -> Color {
            switch legality {
            case "legal":
                return .green
            case "banned":
                return .red
            default:
                return Color.gray.opacity(0.5)
            }
        }

        func legalityTextColor(for legality: String) -> Color {
            return legality == "legal" ? .white : .black
        }
    
    var cardLegalities: Legalities {
        return card.legalities
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
                        .foregroundColor(selectedTab == .version ? .white : .gray)
                        .padding()
                        .background(selectedTab == .version ? Color.red : Color.white)
                        .border(Color.gray, width: 1)
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
                        .background(selectedTab == .ruling ? Color.red : Color.white)
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

                VStack(alignment: .leading) {
                    if selectedTab == .ruling {
                        Text("LEGALITIES").foregroundColor(.orange).fontWeight(.bold).padding(5)
                        HStack {
                            VStack {
                                ForEach(0..<(legalitiesList.count / 2) + 1) { index in
                                    let (label, legality) = legalitiesList[index]
                                    HStack {
                                        Rectangle()
                                            .fill(legalityBackgroundColor(for: legality))
                                            .frame(width: 80, height: 30)
                                            .overlay(
                                                Text(legality.capitalized.replacingOccurrences(of: "_", with: " "))
                                                    .foregroundColor(legalityTextColor(for: legality))
                                                    .frame(alignment: .center)
                                            )

                                        Text(label.capitalized)
                                            .foregroundColor(.black)
                                            .frame(minWidth: 100, alignment: .leading)
                                    }
                                }
                                Spacer()
                            }
                   

                            VStack {
                                ForEach((legalitiesList.count / 2) + 1..<legalitiesList.count) { index in
                                    let (label, legality) = legalitiesList[index]
                                    HStack {
                                        Rectangle()
                                            .fill(legalityBackgroundColor(for: legality))
                                            .frame(width: 80, height: 30)
                                            .overlay(
                                                Text(legality.capitalized.replacingOccurrences(of: "_", with: " "))
                                                    .foregroundColor(legalityTextColor(for: legality))
                                                    .frame(alignment: .center)
                                            )

                                        Text(label.capitalized)
                                            .foregroundColor(.black)
                                            .frame(minWidth: 100, alignment: .leading)
                                    }
                                }
                                Spacer()
                            }
                        }
                        
                        
                    }
                    else if selectedTab == .version {
                        Text("Rarity: \(card.rarity)").padding(5)
                        Text("Artist: \(card.artist)").padding(5)
                        Text("PRICES").foregroundColor(.red).padding(5).fontWeight(.bold).padding(.top,8)
                        // Prices Table
                        if let prices = card.prices {
                            VStack {
                                HStack {
                                    Spacer()
                                    Text("Normal")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text("Foil")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)

                                HStack {
                                    Text("USD")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text(prices.usd ?? "N/A")
                                        .frame(maxWidth: .infinity)
                                        .frame(alignment: .center)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    Text(prices.usd_foil ?? "N/A")
                                        .frame(maxWidth: .infinity)
                                        .frame(alignment: .center)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)

                                HStack {
                                    Text("EUR")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Text(prices.eur ?? "N/A")
                                        .frame(maxWidth: .infinity)
                                        .frame(alignment: .center)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    Text(prices.eur_foil ?? "N/A")
                                        .frame(maxWidth: .infinity)
                                        .frame(alignment: .center)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)

                            }
                            .padding(.top, 2)
                            .padding(5)
                            .background(RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.gray.opacity(0.1))
                                            .shadow(radius: 5))
                        } else {
                            Text("Prices information not available")
                                .padding(.top, 10)
                        }




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



}

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
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
                VStack(spacing: 0) {
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        TextField("Search Cards", text: $searchText)
                            .padding(8)
                            .background(Color(UIColor(hex: "#3A4F67")!))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                HStack {
                                    Spacer()
                                    if !searchText.isEmpty {
                                        Button(action: {
                                            searchText = ""
                                        }) {
                                            Image(systemName: "multiply.circle.fill")
                                                .foregroundColor(.white)
                                                .padding(.trailing, 8)
                                        }
                                    }
                                }
                            )

                        Menu {
                            Button(action: {
                                currentSorting = .ascending
                                cards.sort { $0.name < $1.name }
                            }) {
                                Label("Sort A to Z", systemImage: "arrow.up.circle")
                            }

                            Button(action: {
                                currentSorting = .descending
                                cards.sort { $0.name > $1.name }
                            }) {
                                Label("Sort Z to A", systemImage: "arrow.down.circle")
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .foregroundColor(.white)
                                .padding(.trailing, 8)
                        }
                    }
                    .padding()
                    .background(Color(#colorLiteral(red: 0.1735038753, green: 0.2392750688, blue: 0.3176470697, alpha: 1)))
                    .ignoresSafeArea()
                    .edgesIgnoringSafeArea(.all)
                    
                    
                  
                    Rectangle()
                            .fill(Color(UIColor(hex: "#2C3D51")!))
                            .frame(height: 40)
        
                            .overlay(
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(.white)
                                    Text("Cards")
                                        .foregroundColor(.white)
                                        .font(.system(size: 12))
                                }
                            )
                  
                    
                }





                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(filteredCards) { card in
                        NavigationLink(destination: CardDetail(card: card)) {
                            VStack {
                                RemoteImage(url: card.image_uris.small)
                                    .frame(width: 100, height: 150)

                                Text(card.name)
                                    .font(.caption)
                                    .foregroundColor(.black)
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

