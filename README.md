# Flutter E-Commerce App

A modern e-commerce mobile application built with Flutter, featuring a clean UI design and state management using BLoC pattern.



## Features

### Product Management
- Browse products in a visually appealing grid layout
- Search products by name and category
- Sort products by price, name, and popularity
- View detailed product information
- Category-based filtering

### Shopping Cart
- Add/remove products to cart
- Adjust product quantities
- Swipe to remove items
- View cart subtotal and total
- Clear cart functionality
- Undo remove actions
- Persistent cart data

### User Interface
- Modern, clean design
- Smooth animations and transitions
- Responsive layout
- Empty state handling
- Loading state indicators
- Error state handling
- Pull-to-refresh functionality
- Dark/Light theme support

### State Management
- BLoC pattern implementation
- Stream-based reactive programming
- Efficient data flow
- Persistent storage integration

## Getting Started

### Prerequisites
- Flutter SDK (Version 3.0 or higher)
- Dart SDK (Version 2.17 or higher)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS development)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/FlutterBLoC.git
```

2. Navigate to project directory
```bash
cd FlutterBLoC
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

### Project Structure
```
lib/
├── blocs/
│   ├── cart_bloc.dart
│   └── product_bloc.dart
├── data/
│   ├── cart_service.dart
│   └── product_service.dart
├── models/
│   ├── cart.dart
│   └── product.dart
├── screens/
│   ├── product_list.dart
│   └── cart_screen.dart
├── widgets/
│   ├── cart_widgets.dart
│   └── product_widgets.dart
└── main.dart
```

## Code Examples

### Adding to Cart
```dart
void addToCart(Product product) {
  cartBloc.addToCart(Cart(product, 1));
}
```

### Removing from Cart
```dart
void removeFromCart(Cart cart) {
  cartBloc.removeFromCart(cart);
}
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  shared_preferences: ^2.2.2
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Screenshots

<table>

  <tr>
    <td>Product List</td>
    <td>Empty Cart</td>
  </tr>
  <tr>
    <td><img src="screenshots/productlist.png" width=270></td>
    <td><img src="screenshots/shopingcartempt.png" width=270></td>
  </tr>

  <tr>
    <td> Add to Cart</td>
    <td>Added to Cart</td>
  </tr>
  <tr>
    <td><img src="screenshots/addtocart.png" width=270></td>
    <td><img src="screenshots/addedtoshoppingcart.png" width=270></td>
  </tr>

  <tr>
    <td>Scroll left to Delete</td>
    <td>Delete All</td>
  </tr>
  <tr>
    <td><img src="screenshots/scrollleftfordelet.png" width=270></td>
    <td><img src="screenshots/deleteallproduct.png" width=270></td>
  </tr>

</table>

## Implementation Details

### BLoC Pattern
The app uses the BLoC (Business Logic Component) pattern for state management. This provides:
- Separation of concerns
- Testable business logic
- Reactive state updates
- Easy state debugging

### Cart Implementation
The shopping cart features:
- Real-time total calculation
- Quantity adjustment
- Persistent storage
- Undo functionality
- Clear all option

### UI/UX Features
- Swipe to delete items
- Pull to refresh
- Smooth animations
- Loading indicators
- Error handling
- Empty state displays

## Future Enhancements

- [ ] User authentication
- [ ] Payment integration
- [ ] Order history
- [ ] Wishlist functionality
- [ ] Push notifications
- [ ] Product reviews and ratings
- [ ] Social sharing
- [ ] Address management
- [ ] Multiple language support

## Performance Optimizations

- Efficient list rendering
- Image caching
- Lazy loading
- State management optimization
- Memory management



## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- Flutter team for the amazing framework
- BLoC library contributors
- The Flutter community for their support and feedback

## Contact

Rezwanullah Khan Quraishi - [linkedin](https://www.linkedin.com/in/rezwanullah-quraishi-608314260/)

Project Link: [GitHub](https://github.com/rezwanqkhan/FlutterBLoC)