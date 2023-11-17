# Scryfall-app-W09
Scryfall App
Welcome to the Scryfall App, a user-friendly application designed for Magic: The Gathering (MTG) enthusiasts, built using SwiftUI.
Features:
- Card List Display:
    * View a scrollable comprehensive list of Magic: The Gathering cards.
    * Easily identify foil cards with a small yellow badge in the bottom left corner (foil=true).
    * Tap on a card for detailed information (card details view).
    * Search bar and sort button on the top navigation bar and a bottom navigation bar that sticks
- Search Functionality:
    * Enables users to search for specific cards based on their names.
    * Dynamically updates the displayed cards as the user types.
    * Quick reset with a delete button in the search bar.
    * Custom view UI for no search results.
- Sorting Options:
    * Sort cards alphabetically (A-Z or Z-A).
    * Sort cards ascending or descending based on the collector number
- Bottom Navigation Bar:
    * Five buttons for navigation, with "home," "decks," and "snap" under development (Maintenance view with circular progress view style for unfinished tabs.).
    * Change in button color indicates the active tab.
    * Automatic display of the search view on app launch.
    * Bottom navigation bar hides when viewing a card in detail (card details view).
- Scrollable Card Details View (with a pop-up and tabs):
    * Click on the card's art_crop for a larger image in a pop-up.
    * Users are able to download high-resolution images with the available button (in the pop-up).
    * Displayed details: name, the symbol (mana cost), type, and oracle text.
    * Additional details like rarity, artist, and a price table under the "Details" tab.
    * Legalities for various game formats in the "Ruling" tab.
    * Next and previous buttons for seamless navigation between cards. (Only show when there's a next or previous card)
    * "Add to collection" button to add the card in user's collection tab.
- Swipe Gesture (card details view):
    * Support for swipe gestures for easy navigation in detailed view (swipe right/left).
- Collection View:
    * Display the user's added cards beautifully.
    * Delete cards by using the edit and delete buttons.

![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 29 42](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/72b6b0dc-26fc-4bbe-ade6-a77c3e641557)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 30 01](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/e4255196-df6a-4941-863e-c489ee203596)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 30 29](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/2007d2ec-55ae-4ed7-ad72-73109ec68166)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 30 51](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/a6c8784d-ce7e-42c6-91b0-e167b6147442)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 31 12](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/4bd3d245-27a0-4415-b56f-386ff03cd419)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 31 22](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/2ac7df3f-dc8d-411d-ada6-0035516925cb)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 31 31](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/d66053eb-cfd8-4ec7-8d3a-a3d962bb6d5a)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 31 42](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/c8bd7f82-b453-4ec5-96af-4c15b81ba74d)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 32 11](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/e264d960-a532-44f3-9343-a74477eb5a2a)
![Simulator Screenshot - iPhone 14 Pro - 2023-11-17 at 23 32 22](https://github.com/9wynneth/Scryfall-app-W09/assets/95265271/465f60ca-7ec6-45ee-a6e6-b03b71cd0e15)



Colorful UI & Dynamic Content:
Enjoy a visually appealing and colorful user interface with real-time updates.

Data Source:
JSON file (WOT-Scryfall.json)

Acknowledgments:
This app utilizes the Scryfall API for Magic: The Gathering card data.
Reference: ManaBox app
