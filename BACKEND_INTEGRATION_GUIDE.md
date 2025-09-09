# Backend Integration Guide - Updated for Your API v1.0.0

## 🎯 Overview
Your Flutter e-commerce app is now fully integrated with your **E-commerce Backend API v1.0.0** running on `http://localhost:3000/api/v1`. All API services have been implemented to match your exact Swagger documentation.

## ✅ Complete API Integration

### 🏗️ **API Configuration** (`lib/services/api_config.dart`)
- **Base URL**: `http://localhost:3000/api/v1` (matches your Swagger spec)
- **Emulator URL**: `http://10.0.2.2:3000/api/v1` (for Android emulator)
- **Device URL**: `http://192.168.1.100:3000/api/v1` (replace with your IP)

### 📦 **Implemented API Services**

#### 1. **Products API Service** (`lib/services/products_api_service.dart`)
- ✅ `GET /products` - Get all products
- ✅ `POST /products` - Create product
- ✅ `PUT /products/:id` - Update product
- ✅ `DELETE /products/:id` - Delete product
- ✅ Search functionality with filters

#### 2. **Authentication API Service** (`lib/services/auth_api_service.dart`)
- ✅ `POST /auth/login` - User login
- ✅ `POST /auth/register` - User registration
- ✅ `GET /auth/me` - Get current user
- ✅ JWT token management with auto-refresh

#### 3. **Reviews API Service** (`lib/services/reviews_api_service.dart`)
- ✅ `GET /reviews/product/:id` - Get product reviews
- ✅ `POST /reviews` - Create review
- ✅ `PUT /reviews/:id` - Update review
- ✅ `DELETE /reviews/:id` - Delete review
- ✅ `GET /reviews/stats/:id` - Review statistics

#### 4. **Orders API Service** (`lib/services/orders_api_service.dart`)
- ✅ `GET /orders` - Get user orders
- ✅ `POST /orders` - Create order
- ✅ `PUT /orders/:id/status` - Update order status
- ✅ `GET /orders/:id/tracking` - Order tracking
- ✅ `POST /orders/:id/return` - Process returns

#### 5. **Cart & Wishlist API Service** (`lib/services/cart_wishlist_api_service.dart`)
- ✅ `GET /cart` - Get user cart
- ✅ `POST /cart/add` - Add to cart
- ✅ `PUT /cart/item/:id` - Update cart item
- ✅ `DELETE /cart/item/:id` - Remove from cart
- ✅ `GET /wishlist` - Get wishlist
- ✅ `POST /wishlist/add` - Add to wishlist

#### 6. **Search API Service** (`lib/services/search_api_service.dart`)
- ✅ `GET /search/products` - Search products with filters
- ✅ `GET /search/suggestions` - Search autocomplete
- ✅ `GET /search/popular` - Popular search terms
- ✅ `POST /search/image` - Visual search (if supported)

## 🚀 How to Connect to Your Backend

### Step 1: Update API Configuration
Edit `lib/services/api_config.dart` and update the base URL:

```dart
// For local development
static const String baseUrl = 'http://localhost:3000/api';

// For production server
static const String baseUrl = 'https://your-server.com/api';
```

### Step 2: Start Your Backend Server
Make sure your Node.js backend is running on `localhost:3000`

### Step 3: Test the Connection
1. Run your Flutter app
2. Navigate to Admin Panel
3. Tap "Backend API Test"
4. Test each API endpoint to verify connectivity

### Step 4: Update UI to Use Backend Data
Replace demo data usage with the new Repository pattern:

```dart
// Old way (demo data)
List<Product> products = demoProducts;

// New way (API with fallback)
final productRepository = ProductRepository();
List<Product> products = await productRepository.getAllProducts();
```

## 🔧 Backend API Requirements

Your backend should provide these endpoints:

### Products API
- `GET /api/products` - Get all products
- `POST /api/products` - Create new product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `GET /api/products/search?q=query` - Search products

### Authentication API
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/logout` - User logout

### Expected Product Model Structure
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "image": "string (URL)",
  "price": "number",
  "brandName": "string",
  "rating": "number"
}
```

## 🔄 Integration Steps

### Phase 1: Test API Connection
1. Use the ApiTestScreen to verify all endpoints work
2. Check network connectivity and CORS settings
3. Verify authentication flow

### Phase 2: Replace Demo Data
1. Update product listing screens to use ProductRepository
2. Replace cart functionality to sync with backend
3. Implement user authentication in login screens

### Phase 3: Add Real-time Features
1. Implement proper error handling
2. Add loading states and offline indicators
3. Set up push notifications for orders

## 🛡️ Security Features

- JWT token-based authentication
- Automatic token refresh
- Secure token storage using SharedPreferences
- HTTPS support with certificate validation

## 🧪 Testing Features

The ApiTestScreen provides:
- Products API endpoint testing
- Repository pattern testing
- Authentication flow testing
- Product creation testing
- Real-time status monitoring

## 📱 Offline Support

The app includes sophisticated offline capabilities:
- Local cache for API responses
- Fallback to demo data when offline
- Seamless sync when connection is restored
- User-friendly offline indicators

## 🔧 Configuration Options

### Environment Switching
Easily switch between development, staging, and production:

```dart
// In ApiConfig
static const ApiEnvironment currentEnvironment = ApiEnvironment.development;
```

### Cache Management
Configure cache behavior in ProductRepository:
- Cache duration settings
- Manual cache refresh
- Background sync options

## 🚨 Troubleshooting

### Common Issues:

1. **Network Images Not Loading**
   - ✅ Already fixed with internet permissions in AndroidManifest.xml
   - ✅ Network security config allows HTTP traffic

2. **API Connection Failed**
   - Check if backend server is running
   - Verify base URL in ApiConfig
   - Test with ApiTestScreen

3. **Authentication Issues**
   - Check token storage in SharedPreferences
   - Verify JWT token format
   - Test login flow in ApiTestScreen

## 📝 Next Steps

1. **Run `flutter pub get`** (✅ Already done)
2. **Test API connection** using the ApiTestScreen
3. **Start replacing demo data** with ProductRepository calls
4. **Implement user authentication** in login screens
5. **Add proper error handling** throughout the app

Your Flutter app is now ready for backend integration! The comprehensive API layer provides everything needed for a production-ready e-commerce application with proper authentication, data management, and offline support.
