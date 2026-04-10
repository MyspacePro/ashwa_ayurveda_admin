# Firebase Firestore Data Model (E-commerce Mobile App)

This structure is optimized for **read-heavy mobile usage**, predictable query patterns, and scalable collection growth.

## Core Design Principles

- Use `Timestamp` values from SDK/server (`FieldValue.serverTimestamp()`) for all `createdAt` and time fields.
- Keep top-level collections for globally queried entities (`products`, `orders`, `reviews`, etc.).
- Duplicate minimal display data in subcollections where it reduces app round-trips (example: order item snapshot fields).
- Use reference IDs (`userId`, `productId`, `categoryId`) instead of deep nesting to keep queries flexible.
- Keep documents small and immutable where possible for hot reads.
- Use server-side logic (Cloud Functions/admin APIs) to maintain aggregate fields like `rating`, `totalReviews`, and `stock` consistency.

---

## 1) Users Collection

**Path:** `users/{userId}`

### Fields
- `name` (string)
- `email` (string)
- `phone` (string)
- `profileImage` (string)
- `walletBalance` (number)
- `isKYCVerified` (boolean)
- `isBlocked` (boolean)
- `createdAt` (timestamp)

### Sample document
```json
{
  "name": "Ava Thompson",
  "email": "ava@example.com",
  "phone": "+1-555-0199",
  "profileImage": "https://cdn.example.com/users/u_1001.jpg",
  "walletBalance": 125.5,
  "isKYCVerified": true,
  "isBlocked": false,
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 2) Products Collection

**Path:** `products/{productId}`

### Fields
- `name` (string)
- `description` (string)
- `price` (number)
- `discountPrice` (number)
- `images` (array<string>)
- `categoryId` (string)
- `stock` (number)
- `isActive` (boolean)
- `rating` (number)
- `totalReviews` (number)
- `createdAt` (timestamp)

### Sample document
```json
{
  "name": "Organic Turmeric Powder",
  "description": "Premium-grade turmeric powder for daily wellness.",
  "price": 18.99,
  "discountPrice": 14.99,
  "images": [
    "https://cdn.example.com/products/p_5001_1.jpg",
    "https://cdn.example.com/products/p_5001_2.jpg"
  ],
  "categoryId": "cat_herbs",
  "stock": 240,
  "isActive": true,
  "rating": 4.6,
  "totalReviews": 183,
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 3) Categories Collection

**Path:** `categories/{categoryId}`

### Fields
- `name` (string)
- `image` (string)
- `parentId` (string | null)
- `isActive` (boolean)
- `createdAt` (timestamp)

### Sample document
```json
{
  "name": "Herbal Powders",
  "image": "https://cdn.example.com/categories/herbal_powders.jpg",
  "parentId": null,
  "isActive": true,
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 4) Orders Collection

**Path:** `orders/{orderId}`

### Fields
- `userId` (string)
- `totalAmount` (number)
- `discount` (number)
- `finalAmount` (number)
- `paymentMethod` (string)
- `paymentStatus` (string)
- `orderStatus` (string)
- `address` (map)
  - `name` (string)
  - `phone` (string)
  - `city` (string)
  - `pincode` (string)
  - `fullAddress` (string)
- `couponCode` (string)
- `createdAt` (timestamp)

### Sample document
```json
{
  "userId": "u_1001",
  "totalAmount": 89.97,
  "discount": 10,
  "finalAmount": 79.97,
  "paymentMethod": "UPI",
  "paymentStatus": "PAID",
  "orderStatus": "PLACED",
  "address": {
    "name": "Ava Thompson",
    "phone": "+1-555-0199",
    "city": "Austin",
    "pincode": "73301",
    "fullAddress": "221B Baker Heights, Apt 4"
  },
  "couponCode": "WELCOME10",
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 5) Order Items Subcollection

**Path:** `orders/{orderId}/items/{itemId}`

### Fields
- `productId` (string)
- `name` (string)
- `price` (number)
- `quantity` (number)
- `image` (string)

### Sample document
```json
{
  "productId": "p_5001",
  "name": "Organic Turmeric Powder",
  "price": 14.99,
  "quantity": 2,
  "image": "https://cdn.example.com/products/p_5001_1.jpg"
}
```

> Keep product name/image/price snapshot here to preserve historical order context even if product data changes later.

---

## 6) Reviews Collection

**Path:** `reviews/{reviewId}`

### Fields
- `userId` (string)
- `productId` (string)
- `rating` (number)
- `review` (string)
- `createdAt` (timestamp)

### Sample document
```json
{
  "userId": "u_1001",
  "productId": "p_5001",
  "rating": 5,
  "review": "Excellent quality and very fresh.",
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 7) Notifications Subcollection

**Path:** `notifications/{userId}/messages/{notificationId}`

### Fields
- `title` (string)
- `message` (string)
- `isRead` (boolean)
- `createdAt` (timestamp)

### Sample document
```json
{
  "title": "Order Shipped",
  "message": "Your order #ord_9001 has been shipped.",
  "isRead": false,
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 8) Coupons Collection

**Path:** `coupons/{couponId}`

### Fields
- `code` (string)
- `discountType` (string: `PERCENT` or `FLAT`)
- `discountValue` (number)
- `maxDiscount` (number)
- `minOrderAmount` (number)
- `expiryDate` (timestamp)
- `isActive` (boolean)
- `createdAt` (timestamp)

### Sample document
```json
{
  "code": "WELCOME10",
  "discountType": "PERCENT",
  "discountValue": 10,
  "maxDiscount": 20,
  "minOrderAmount": 50,
  "expiryDate": "<Firestore Timestamp>",
  "isActive": true,
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 9) Banners Collection (Admin Controlled)

**Path:** `banners/{bannerId}`

### Fields
- `image` (string)
- `title` (string)
- `link` (string)
- `isActive` (boolean)
- `createdAt` (timestamp)

### Sample document
```json
{
  "image": "https://cdn.example.com/banners/summer_sale.jpg",
  "title": "Summer Wellness Sale",
  "link": "app://category/cat_herbs",
  "isActive": true,
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 10) Support Tickets Collection

**Path:** `tickets/{ticketId}`

### Fields
- `userId` (string)
- `issue` (string)
- `status` (string: `OPEN`, `CLOSED`, `IN_PROGRESS`)
- `createdAt` (timestamp)

### Sample document
```json
{
  "userId": "u_1001",
  "issue": "Payment deducted but order not visible.",
  "status": "OPEN",
  "createdAt": "<Firestore Timestamp>"
}
```

---

## 11) User Wallet / Transactions Subcollection

**Path:** `users/{userId}/transactions/{transactionId}`

### Fields
- `amount` (number)
- `type` (string: `CREDIT` or `DEBIT`)
- `description` (string)
- `createdAt` (timestamp)

### Sample document
```json
{
  "amount": 50,
  "type": "CREDIT",
  "description": "Cashback for order ord_9001",
  "createdAt": "<Firestore Timestamp>"
}
```

---

## Relationships (Reference Model)

- `orders.userId` → `users/{userId}`
- `orders/{orderId}/items[].productId` → `products/{productId}`
- `products.categoryId` → `categories/{categoryId}`
- `reviews.userId` → `users/{userId}`
- `reviews.productId` → `products/{productId}`
- `tickets.userId` → `users/{userId}`
- `notifications/{userId}` logically maps to `users/{userId}`
- `users/{userId}/transactions` belongs to that user document

---

## Index Recommendations

Create composite indexes based on expected app queries:

1. **Products listing by active/category/sort**
   - Collection: `products`
   - Fields: `isActive` (ASC), `categoryId` (ASC), `createdAt` (DESC)

2. **Products listing by active/category/price**
   - Collection: `products`
   - Fields: `isActive` (ASC), `categoryId` (ASC), `discountPrice` (ASC)

3. **User order history (latest first)**
   - Collection: `orders`
   - Fields: `userId` (ASC), `createdAt` (DESC)

4. **Admin order queue by status**
   - Collection: `orders`
   - Fields: `orderStatus` (ASC), `createdAt` (DESC)

5. **Product reviews feed**
   - Collection: `reviews`
   - Fields: `productId` (ASC), `createdAt` (DESC)

6. **Unread notifications first**
   - Collection group or subcollection: `messages`
   - Fields: `isRead` (ASC), `createdAt` (DESC)

7. **Coupon validation**
   - Collection: `coupons`
   - Fields: `code` (ASC)
   - Optionally: `isActive` (ASC), `expiryDate` (DESC) for admin lists

8. **User wallet ledger**
   - Subcollection: `users/{userId}/transactions`
   - Fields: `createdAt` (DESC)

> Keep single-field indexes enabled by default and selectively disable high-cardinality fields only when index storage costs become significant.

---

## Read-heavy App Optimizations

- Store commonly displayed product summary fields directly in `orders/{orderId}/items/*` to avoid extra product lookups in order history.
- Keep `rating` and `totalReviews` inside product docs so product cards render in one read.
- Serve home screen with dedicated small queries:
  - active banners (`banners.where(isActive == true)`)
  - featured/new products (`products.where(isActive == true).orderBy(createdAt, desc)`)
  - active root categories (`categories.where(isActive == true).where(parentId == null)`)
- Paginate all large lists (`limit + startAfterDocument`).
- Keep docs under Firestore size limits by avoiding large embedded arrays/maps for high-growth entities.

---

## Optional Validation Rules (Recommended)

- Restrict enum-like fields:
  - `discountType ∈ {PERCENT, FLAT}`
  - `status ∈ {OPEN, CLOSED, IN_PROGRESS}`
  - `type ∈ {CREDIT, DEBIT}`
- Numeric sanity:
  - `price >= 0`, `discountPrice >= 0`, `stock >= 0`, `rating ∈ [0, 5]`
- Prevent clients from directly editing sensitive fields (`walletBalance`, `paymentStatus`, `orderStatus`) unless through trusted backend/admin flows.

