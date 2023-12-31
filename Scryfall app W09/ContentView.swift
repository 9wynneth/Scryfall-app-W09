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
    let set_name: String
    let foil: Bool
    let collector_number: String
    

    
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
                    Image(uiImage: symbol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    Image(uiImage: symbol)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }
                
            }
        }
    }
}

extension String {
    var manaSymbols: [UIImage] {
        var symbols: [UIImage] = []

        for character in self {
            switch character {
            case "W":
                symbols.append(UIImage(named: "white") ?? UIImage())
            case "U":
                symbols.append(UIImage(named: "blue") ?? UIImage())
            case "B":
                symbols.append(UIImage(named: "black") ?? UIImage())
            case "R":
                symbols.append(UIImage(named: "red") ?? UIImage())
            case "G":
                symbols.append(UIImage(named: "green") ?? UIImage())
            case "1":
                symbols.append(UIImage(named: "one") ?? UIImage())
            case "2":
                symbols.append(UIImage(named: "two") ?? UIImage())
            case "3":
                symbols.append(UIImage(named: "three") ?? UIImage())
            case "4":
                symbols.append(UIImage(named: "four") ?? UIImage())
            case "5":
                symbols.append(UIImage(named: "five") ?? UIImage())
            case "0":
                symbols.append(UIImage(named: "zero") ?? UIImage())
            case "7":
                symbols.append(UIImage(named: "seven") ?? UIImage())
            default:
                if let intValue = Int(String(character)) {
                    symbols.append(UIImage(named: "") ?? UIImage())
                }
            }
        }

        return symbols
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(
            RoundedCorner(radius: radius, corners: corners)
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius*2, height: radius)
        )
        return Path(path.cgPath)
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
                .bold(true)
                .opacity(isPopupPresented ? 0.5 : 1.0)
        }
    }
}



struct CardDetail: View {
    @Environment(\.presentationMode) var presentationMode

    let card: Card
    @State var currentIndex: Int
    let cards: [Card] // Add this property
    @State private var isPopupPresented = false
    @State private var selectedTab: Tab = .version // Default selected tab
    @State private var imageSize: CGFloat = 100
    @State private var navBarColor: Color = .clear
    @Binding var collection: [Card]
    @State private var showAlert = false



    private func showAlertFunc() {
        showAlert = true
    }

    init(card: Card, currentIndex: Int, cards: [Card], collection: Binding<[Card]>) {
        self.card = card
        self._currentIndex = State(initialValue: currentIndex)
        self.cards = cards
        self._collection = collection

    }

    enum Tab {
        case version
        case ruling
    }

    var legalitiesList: [(String, String)] {
        let mirror = Mirror(reflecting: cards[currentIndex].legalities)
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
        return cards[currentIndex].legalities
    }

    private var hasPreviousCard: Bool {
        return currentIndex > 0
    }

    private var hasNextCard: Bool {
        return currentIndex < cards.count - 1
    }

    private func previousCard() {
        withAnimation {
            if hasPreviousCard {
                currentIndex -= 1
            }
        }
    }

    private func nextCard() {
        withAnimation {
            if hasNextCard {
                currentIndex += 1
            }
        }
    }
    
    func addToCollection() {
            if !collection.contains(where: { $0.id == card.id }) {
                collection.append(card)
                showAlertFunc()
            } else {
                print("Card is already in the collection.")
            }
        }
    
    
    private func replaceSymbolsWithImages(text: String) -> Text {
        var modifiedText = text
        modifiedText = modifiedText.replacingOccurrences(of: "{W/B}", with: imageForSymbol("{W/B}"))
        modifiedText = modifiedText.replacingOccurrences(of: "{2}", with: imageForSymbol("{2}"))
        return Text(modifiedText)
    }

    private func imageForSymbol(_ symbol: String) -> String {
        let imageName = symbol
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "/", with: "")
            .appending(".png")

        return imageName
    }
    
  

    var body: some View {
        ZStack {
            GeometryReader { geometry in

                ScrollView {
                 
                    ZStack {
                        RemoteImage(url: cards[currentIndex].image_uris.art_crop)
                            .aspectRatio(contentMode: .fill)
                            .frame(height: UIScreen.main.bounds.height / 4)
                            .edgesIgnoringSafeArea(.top)
                            .padding(.top, 0)
                            .offset(y: -30)
                            .onTapGesture {
                                isPopupPresented.toggle()
                            }

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding(5)
                                .font(Font.system(size: 20, weight: .bold))

                        
                        }
                        .padding(5)
                        .padding(.top, 10)
                        .frame (alignment:.leading)
                        .offset(x: -UIScreen.main.bounds.width / 2 + 30, y: -UIScreen.main.bounds.height / 8)

                    }
                    

                    HStack {
                        Text(cards[currentIndex].name)
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(5)

                        Spacer()
                        ManaCostView(manaCost: cards[currentIndex].mana_cost)
                            .padding(10)
                    }

                    VStack(spacing: 2) {
                        Text(cards[currentIndex].type_line)
                            .font(.headline)
                            .padding(5)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: -15)
          
                        Text(cards[currentIndex].oracle_text.replacingOccurrences(of: "\n", with: "\n\n"))
                            .font(.body)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.gray.opacity(0.1))
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                    .padding(5)

                            ).frame(maxWidth: .infinity)

     
                        VStack {

                            
                            
                            HStack {
                                Spacer()
                                if hasPreviousCard {
                                    Button(action: {
                                        withAnimation {
                                            self.previousCard()
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(.gray)
                                            .padding(5)
                                            .font(Font.system(size: 20, weight: .bold))

                                    }
                                    .disabled(!hasPreviousCard)
                                }
                                Spacer()
                                Button(action: {
                                    selectedTab = .version
                                }) {
                                    Text("Details")
                                        .foregroundColor(selectedTab == .version ? .white : .gray)
                                        .padding(.horizontal,45)
                                        .padding(.vertical,15)
                                        .background(selectedTab == .version ? Color.red : Color.white)
                                        .border(Color.gray, width: 1)
                                        .clipShape(Capsule(style: .continuous))
                                        .frame(maxWidth: .infinity)
                                }
                                Spacer()
                                
                                Button(action: {
                                    selectedTab = .ruling
                                }) {
                                    Text("Ruling")
                                        .foregroundColor(selectedTab == .ruling ? .white : .gray)
                                        .padding(.horizontal,45)
                                        .padding(.vertical,15)
                                        .background(selectedTab == .ruling ? Color.red : Color.white)
                                        .border(Color.gray, width: 1)
                                        .clipShape(Capsule(style: .continuous))
                                        .frame(maxWidth: .infinity, maxHeight: 50)
                                }
                                
                                Spacer()
                                
                                if hasNextCard {
                                    Button(action: {
                                        withAnimation {
                                            self.nextCard()
                                        }
                                    }) {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .padding(5)
                                            .font(Font.system(size: 20, weight: .bold))

                                    }
                                    .disabled(!hasNextCard)
                                    
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .overlay(Rectangle().frame(height: 1).foregroundColor(Color(UIColor(hex: "#2C3D51")!)), alignment: .top)
                   }
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


                        } else if selectedTab == .version {
                            Text("Rarity: \(cards[currentIndex].rarity)").padding(5)
                            Text("Artist: \(cards[currentIndex].artist)").padding(5)
                            Text("PRICES").foregroundColor(.orange).padding(5).fontWeight(.bold).padding(.top,8)

                            VStack(spacing:0) {

                                Text(cards[currentIndex].set_name)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: 40)

                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red)
                                    ).frame(maxWidth: .infinity, maxHeight: 20)
                                    .edgesIgnoringSafeArea(.all)
                                    .padding(.horizontal, -5)


                                // Prices Table
                                if let prices = cards[currentIndex].prices {
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

                            }.frame(maxWidth: .infinity)
                        }
                    }
                    Button(action: {
                        addToCollection()
                    }) {
                        Text("Add to Collection")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(UIColor(hex: "#2C3D51")!))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Added to your collection successfully"),
                            message: Text("Check it out on your collection"),
                            dismissButton: .default(Text("OKAY"))
                        )
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .navigationBarItems(leading: CustomBackButton(isPopupPresented: $isPopupPresented))
                

                if isPopupPresented {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPopupPresented.toggle()
                        }

                    ZStack {
                        RemoteImage(url: cards[currentIndex].image_uris.large)
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
                                if let url = URL(string: cards[currentIndex].image_uris.png) {
                                    UIApplication.shared.open(url)
                                }
                            }

                    }
                    .transition(.opacity)
                    .animation(.easeInOut)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.gesture(
                DragGesture()
                    .onEnded { gesture in
                        let swipeDistance = gesture.translation.width

                        if swipeDistance < -50 && currentIndex < cards.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        } else if swipeDistance > 50 && currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                            }
                        }
                        
                    }
            )
            
            
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


struct NoResultsView: View {
    var body: some View {
        HStack {
            VStack {
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                    .padding(.top, 250)
                Text("No results")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 250)
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .offset(x:150)
            

        
    }
}


enum SelectedTab {
    case home, search, collection, decks, scan
}
struct BottomNavBarButton: View {
    let tab: SelectedTab
    let text: String
    let imageName: String
    @Binding var selectedTab: SelectedTab

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? .blue : .gray)
            Text(text)
                .font(.caption)
                .foregroundColor(selectedTab == tab ? .blue : .gray)
        }
    }
}
struct CardItem: View {
    let card: Card

    var body: some View {
        VStack {
            RemoteImage(url: card.image_uris.small)
                .cornerRadius(10)
                .frame(width: 100, height: 150)

            Text(card.name)
                .font(.caption)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 5)
        }
    }
}


extension View {
  func navigationBarBackground(_ background: Color = Color(UIColor(hex: "#2C3D51")!)) -> some View {
    return self
      .modifier(ColoredNavigationBar(background: background))
  }
}

struct ColoredNavigationBar: ViewModifier {
  var background: Color
  
  func body(content: Content) -> some View {
    content
      .toolbarBackground(
        background,
        for: .navigationBar
      )
      .toolbarBackground(.visible, for: .navigationBar)
  }
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var searchText = ""
    @State private var currentSorting: CardSorting = .ascending
    @State private var currentIndex = 0
    @State private var selectedTab: SelectedTab = .search
    @State private var isCardDetailViewActive = false
    @State private var collection: [Card] = []
    @State private var recentlyViewed: [Card] = []

    

    
    private func bottomNavBar() -> some View {
        HStack {
            BottomNavBarButton(tab: .home, text: "Home", imageName: "house", selectedTab: $selectedTab)
                .onTapGesture {
                    selectedTab = .home
                }
                .padding(.horizontal)

            BottomNavBarButton(tab: .search, text: "Search", imageName: "magnifyingglass", selectedTab: $selectedTab)
                .onTapGesture {
                    selectedTab = .search
                }
                .padding(.horizontal)

            BottomNavBarButton(tab: .collection, text: "Collection", imageName: "folder", selectedTab: $selectedTab)
                .onTapGesture {
                    selectedTab = .collection
                }
                .padding(.horizontal)

            BottomNavBarButton(tab: .decks, text: "Decks", imageName: "doc.plaintext", selectedTab: $selectedTab)
                .onTapGesture {
                    selectedTab = .decks
                }
                .padding(.horizontal)

            BottomNavBarButton(tab: .scan, text: "Scan", imageName: "camera", selectedTab: $selectedTab)
                .onTapGesture {
                    selectedTab = .scan
                }
                .padding(.horizontal)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private struct HomeView: View {
        @Binding var selectedTab: SelectedTab
        @Binding var recentlyViewed: [Card]
//        @State private var recentlyViewed: [Card] = loadRecentlyViewed()

        var bottomNavBar: () -> AnyView
        
        var body: some View {
            VStack {
                
            }
//            ZStack {
//                NavigationView {
//                    ForEach(recentlyViewed) { card in
//                        NavigationLink(destination: CardDetail(card: card, currentIndex: 0, cards: recentlyViewed, collection: $recentlyViewed)) {
//                            Text(card.name)
//                        }
//                    }
////                    .onDelete { indexSet in
////                        deleteItem(at: indexSet)
////                    }
//
//                }
//                .onAppear {
//                    recentlyViewed = loadRecentlyViewed()
//                }
//                bottomNavBar()
//                .offset(y: 370)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        mutating private func deleteItem(at offsets: IndexSet) {
            recentlyViewed.remove(atOffsets: offsets)
        }

        
        private func loadRecentlyViewed() -> [Card] {
            if let data = UserDefaults.standard.data(forKey: "RecentlyViewedCards") {
                do {
                    let decoder = JSONDecoder()
                    let recentlyViewed = try decoder.decode([Card].self, from: data)
                    return recentlyViewed
                } catch {
                    print("Error decoding recently viewed cards: \(error)")
                }
            }
            return []
        }

        
    }
    
    private struct InProgressView: View {
        @Binding var selectedTab: SelectedTab
        var bottomNavBar: () -> AnyView

        var body: some View {
            ZStack {
                VStack {
                    Spacer()
                    ProgressView("Maintenance")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    Spacer()
                }
                bottomNavBar()
                    .offset(y: 370)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
        }
    }
    
    private struct CollectionView: View {
        @Binding var selectedTab: SelectedTab
        @Binding var collection: [Card]
        @State private var isEditing = false
        var bottomNavBar: () -> AnyView
        
        var body: some View {
            ZStack {
                NavigationView {
                    ScrollView {
                        Text("My Collection")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 10) {
                            ForEach(collection.indices, id: \.self) { index in
                                NavigationLink(destination: CardDetail(card: collection[index], currentIndex: 0, cards: collection, collection: $collection)) {
                                    VStack {
                                        ZStack(alignment: .bottomTrailing) {
                                            RemoteImage(url: collection[index].image_uris.small)
                                                .cornerRadius(10)
                                                .frame(width: (UIScreen.main.bounds.width - 30) / 3, height: 150)
                                            
                                            if collection[index].foil {
                                                Spacer()
                                                BadgeView(text: "F")
                                                    .offset(x: -8, y: -5)
                                            }
                                        }
                                        
                                        HStack {
                                            if isEditing {
                                                Spacer()
                                                deleteButton(index: index)
                                            }
                                            Text(collection[index].name)
                                                .font(.caption)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: deleteItem)
                        }
                        .padding(.top, 10)
                        .navigationBarItems(trailing: editButton)
                        .navigationBarBackground()
                        .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .overlay(bottomNavBar(), alignment: .bottom)
                }
            }
        }
        
        private var editButton: some View {
            Button(action: {
                withAnimation {
                    isEditing.toggle()
                }
            }) {
                Text(isEditing ? "Done" : "Edit")
            }
        }
        
        private func deleteItem(at offsets: IndexSet) {
            collection.remove(atOffsets: offsets)
        }
        
        private func deleteButton(index: Int) -> some View {
            Button(action: {
                deleteItem(at: IndexSet([index]))
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }



    struct BadgeView: View {
        var text: String
        
        var body: some View {
            Circle()
                .foregroundColor(.yellow)
                .frame(width: 15, height: 15)
                .overlay(
                    Text(text)
                        .foregroundColor(.black)
                        .font(.system(size: 8).bold())
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 5)
        }
    }

    
    
    enum CardSorting: String {
        case ascending = "A-Z"
        case descending = "Z-A"
        case ascNumber = "ASC Collector number"
        case dscNumber = "DESC Collector number"
    }

    var filteredCards: [Card] {
        if searchText.isEmpty {
            return cards
        } else {
            return cards.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.collector_number.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    
    private func handleCardTap(_ card: Card) {
        if let index = recentlyViewed.firstIndex(where: { $0.id == card.id }) {
            recentlyViewed.remove(at: index)
        }
        
        recentlyViewed.insert(card, at: 0)
        
        if recentlyViewed.count > 20 {
            recentlyViewed = Array(recentlyViewed.prefix(20))
        }
        
        // Save to UserDefaults
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentlyViewed)
            UserDefaults.standard.set(data, forKey: "RecentlyViewedCards")
        } catch {
            print("Error encoding recently viewed cards: \(error)")
        }
    }



    var body: some View {
        if selectedTab == .scan || selectedTab == .decks || selectedTab == .home {
            InProgressView(selectedTab: $selectedTab, bottomNavBar: { AnyView(self.bottomNavBar()) })
        }
//        else if selectedTab == .home {
//            HomeView(selectedTab: $selectedTab, recentlyViewed: $recentlyViewed, bottomNavBar: { AnyView(self.bottomNavBar()) })
//        }
        else if selectedTab == .collection {
            CollectionView(selectedTab: $selectedTab, collection: $collection, bottomNavBar: { AnyView(self.bottomNavBar()) })
        }

        else {
            ZStack(alignment: .bottom) {
                NavigationView {
                    VStack(spacing: 0) {
                        ZStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.leading, 8)
                                TextField("", text: $searchText, prompt: Text("Search Cards").foregroundColor(.white.opacity(0.5)))
                                    .padding(10)
                                    .background(Color(UIColor(hex: "#364a61")!))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .disableAutocorrection(true)
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
                                        }.foregroundColor(.white)
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
                                    Button(action: {
                                        currentSorting = .ascNumber
                                        cards.sort { Int($0.collector_number) ?? 0 < Int($1.collector_number) ?? 0 }
                                    }) {
                                        Label("ASC Collector Number", systemImage: "arrow.up.circle")
                                    }
                                    
                                    Button(action: {
                                        currentSorting = .dscNumber
                                        cards.sort { Int($0.collector_number) ?? 0 > Int($1.collector_number) ?? 0 }
                                    }) {
                                        Label("DESC Collector Number", systemImage: "arrow.down.circle")
                                    }
                                } label: {
                                    Image(systemName: "arrow.up.arrow.down.circle")
                                        .foregroundColor(.white)
                                        .padding(.trailing, 8)
                                }
                            }
                            .padding(.top,70)
                            .background(Color(#colorLiteral(red: 0.1735038753, green: 0.2392750688, blue: 0.3176470697, alpha: 1)))
                            .ignoresSafeArea(edges: .top)
                            
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
                                .padding(.top,50)
                                .ignoresSafeArea()
                                .edgesIgnoringSafeArea(.all)
                        }
                        ScrollView {
                            
                            LazyVGrid(columns: [
                                GridItem(.fixed((UIScreen.main.bounds.width - 30) / 3)),
                                GridItem(.fixed((UIScreen.main.bounds.width - 30) / 3)),
                                GridItem(.fixed((UIScreen.main.bounds.width - 30) / 3))
                            ], spacing: 10) {
                                if searchText.isEmpty || !filteredCards.isEmpty {
                                    ForEach(filteredCards.indices, id: \.self) { index in
                                        NavigationLink(
                                            destination: CardDetail(card: filteredCards[index], currentIndex: index, cards: filteredCards, collection: $collection)
                                        ) {
                                            VStack {
                                                ZStack(alignment: .bottomLeading) {
                                                    RemoteImage(url: filteredCards[index].image_uris.small)
                                                        .cornerRadius(10)
                                                        .frame(width: (UIScreen.main.bounds.width - 30) / 3, height: 150)
                                                    
                                                    VStack {
                                                        Spacer()
                                                        HStack {
                                                            if filteredCards[index].foil {
                                                                        Circle()
                                                                            .foregroundColor(.yellow)
                                                                            .frame(width: 15, height: 15)
                                                                            .overlay(
                                                                                Text("F")
                                                                                    .foregroundColor(.black)
                                                                                    .font(.system(size: 8).bold())
                                                                            )
                                                                            .padding(.horizontal, 8)
                                                                            .padding(.bottom, 5)
                                                                    }
                                                        }
                                                    }
                                                }
                                                
                                                Text(filteredCards[index].name)
                                                    .font(.caption)
                                                    .foregroundColor(.black)
                                            }

                                        }
                                        .onTapGesture {
                                                    handleCardTap(filteredCards[index])
                                                    selectedTab = .search
                                                    isCardDetailViewActive = true
                                                }
                                    }
                                } else {
                                    NoResultsView()
                                }
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                    .overlay(bottomNavBar(), alignment: .bottom)
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
                    .background(Color(UIColor(hex: "#2C3D51")!)) // background color of the content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.all)
        }
    }
}


