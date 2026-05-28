# Seed Data for ServiceHub

This file contains sample data for testing the application. You can manually add these documents to your Firestore database.

## How to Add Seed Data

### Option 1: Manual Addition via Firebase Console

1. Go to Firebase Console > Firestore Database
2. For each document below:
   - Click "+" next to collection name
   - Create new document with the ID shown
   - Copy the data fields into the document
   - Click Save

### Option 2: Using Firebase CLI

First, install Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
firebase init firestore
```

Then create a script to import data:
```bash
firebase firestore:delete [collection] --recursive
# Then import using appropriate tool
```

## Sample Data

### Users Collection

#### Document ID: `user1`
```json
{
  "id": "user1",
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "phone": "+1-555-0101",
  "profileImage": "",
  "location": "New York, NY",
  "rating": 4.5,
  "totalReviews": 12,
  "createdAt": "2024-05-01T08:30:00Z",
  "isActive": true
}
```

#### Document ID: `user2`
```json
{
  "id": "user2",
  "name": "Bob Smith",
  "email": "bob@example.com",
  "phone": "+1-555-0102",
  "profileImage": "",
  "location": "Los Angeles, CA",
  "rating": 4.8,
  "totalReviews": 8,
  "createdAt": "2024-05-02T09:15:00Z",
  "isActive": true
}
```

#### Document ID: `user3`
```json
{
  "id": "user3",
  "name": "Carol White",
  "email": "carol@example.com",
  "phone": "+1-555-0103",
  "profileImage": "",
  "location": "Chicago, IL",
  "rating": 4.2,
  "totalReviews": 5,
  "createdAt": "2024-05-03T10:45:00Z",
  "isActive": true
}
```

### Providers Collection

#### Document ID: `provider1`
```json
{
  "id": "provider1",
  "name": "Expert Plumbing Services",
  "email": "expertplumber@example.com",
  "phone": "+1-555-1001",
  "profileImage": "",
  "location": "New York, NY",
  "services": ["Plumber", "Home Repair"],
  "bio": "15+ years of experience in plumbing and home repairs",
  "hourlyRate": 60.0,
  "rating": 4.9,
  "totalReviews": 47,
  "totalJobs": 215,
  "skills": ["Pipe Installation", "Leak Detection", "Drain Cleaning", "Bathroom Fixtures"],
  "availability": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
  "isApproved": true,
  "isActive": true,
  "totalEarnings": 12900.0,
  "createdAt": "2024-04-01T07:00:00Z",
  "documentVerificationDate": "2024-04-05T10:00:00Z"
}
```

#### Document ID: `provider2`
```json
{
  "id": "provider2",
  "name": "ElectroFix Solutions",
  "email": "electrician@example.com",
  "phone": "+1-555-1002",
  "profileImage": "",
  "location": "New York, NY",
  "services": ["Electrician"],
  "bio": "Licensed electrician with 10 years experience",
  "hourlyRate": 75.0,
  "rating": 4.7,
  "totalReviews": 32,
  "totalJobs": 128,
  "skills": ["Electrical Wiring", "Circuit Installation", "Panel Upgrade", "Lighting Design"],
  "availability": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
  "isApproved": true,
  "isActive": true,
  "totalEarnings": 9600.0,
  "createdAt": "2024-04-10T08:30:00Z",
  "documentVerificationDate": "2024-04-15T11:00:00Z"
}
```

#### Document ID: `provider3`
```json
{
  "id": "provider3",
  "name": "Professional Auto Mechanics",
  "email": "mechanic@example.com",
  "phone": "+1-555-1003",
  "profileImage": "",
  "location": "Los Angeles, CA",
  "services": ["Mechanic"],
  "bio": "Full-service auto repair and maintenance",
  "hourlyRate": 85.0,
  "rating": 4.8,
  "totalReviews": 56,
  "totalJobs": 189,
  "skills": ["Engine Repair", "Transmission Service", "Brake Systems", "Oil Changes"],
  "availability": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
  "isApproved": true,
  "isActive": true,
  "totalEarnings": 16065.0,
  "createdAt": "2024-03-15T06:45:00Z",
  "documentVerificationDate": "2024-03-20T09:30:00Z"
}
```

#### Document ID: `provider4`
```json
{
  "id": "provider4",
  "name": "Master Carpenter",
  "email": "carpenter@example.com",
  "phone": "+1-555-1004",
  "profileImage": "",
  "location": "Chicago, IL",
  "services": ["Carpenter", "Home Repair"],
  "bio": "Expert woodworking and home renovation",
  "hourlyRate": 70.0,
  "rating": 4.6,
  "totalReviews": 28,
  "totalJobs": 95,
  "skills": ["Custom Carpentry", "Cabinet Making", "Door Installation", "Furniture Repair"],
  "availability": ["Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
  "isApproved": true,
  "isActive": true,
  "totalEarnings": 6650.0,
  "createdAt": "2024-04-20T09:00:00Z",
  "documentVerificationDate": "2024-04-25T02:00:00Z"
}
```

#### Document ID: `provider5` (Pending Approval)
```json
{
  "id": "provider5",
  "name": "AC Cool Solutions",
  "email": "actechnician@example.com",
  "phone": "+1-555-1005",
  "profileImage": "",
  "location": "Los Angeles, CA",
  "services": ["AC Technician"],
  "bio": "Air conditioning and HVAC services",
  "hourlyRate": 80.0,
  "rating": 0.0,
  "totalReviews": 0,
  "totalJobs": 0,
  "skills": ["AC Installation", "Maintenance", "Repair"],
  "availability": ["Monday", "Wednesday", "Friday"],
  "isApproved": false,
  "isActive": true,
  "totalEarnings": 0.0,
  "createdAt": "2024-05-25T12:00:00Z",
  "documentVerificationDate": null
}
```

### Bookings Collection

#### Document ID: `booking1`
```json
{
  "id": "booking1",
  "userId": "user1",
  "providerId": "provider1",
  "serviceType": "Plumber",
  "description": "Leaky kitchen faucet needs fixing",
  "scheduledTime": "2024-06-10T14:00:00Z",
  "estimatedCost": 60.0,
  "finalCost": 75.0,
  "status": "completed",
  "location": "123 Main Street, New York, NY",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "createdAt": "2024-05-25T10:30:00Z",
  "completedAt": "2024-06-10T15:30:00Z",
  "cancellationReason": null,
  "paymentDetails": {
    "method": "creditCard",
    "transactionId": "TXN123456789",
    "status": "completed"
  }
}
```

#### Document ID: `booking2`
```json
{
  "id": "booking2",
  "userId": "user2",
  "providerId": "provider2",
  "serviceType": "Electrician",
  "description": "Install new ceiling fan",
  "scheduledTime": "2024-06-15T10:00:00Z",
  "estimatedCost": 75.0,
  "finalCost": 0.0,
  "status": "accepted",
  "location": "456 Oak Avenue, Los Angeles, CA",
  "latitude": 34.0522,
  "longitude": -118.2437,
  "createdAt": "2024-05-26T09:00:00Z",
  "completedAt": null,
  "cancellationReason": null,
  "paymentDetails": {}
}
```

#### Document ID: `booking3`
```json
{
  "id": "booking3",
  "userId": "user3",
  "providerId": "provider3",
  "serviceType": "Mechanic",
  "description": "Car oil change and filter replacement",
  "scheduledTime": "2024-06-12T11:00:00Z",
  "estimatedCost": 85.0,
  "finalCost": 0.0,
  "status": "pending",
  "location": "789 Elm Street, Chicago, IL",
  "latitude": 41.8781,
  "longitude": -87.6298,
  "createdAt": "2024-05-27T08:30:00Z",
  "completedAt": null,
  "cancellationReason": null,
  "paymentDetails": {}
}
```

### Reviews Collection

#### Document ID: `review1`
```json
{
  "id": "review1",
  "bookingId": "booking1",
  "userId": "user1",
  "providerId": "provider1",
  "rating": 5.0,
  "comment": "Excellent service! Fixed the leak quickly and professionally. Highly recommend!",
  "images": [],
  "createdAt": "2024-06-10T16:00:00Z"
}
```

### Payments Collection

#### Document ID: `payment1`
```json
{
  "id": "payment1",
  "bookingId": "booking1",
  "userId": "user1",
  "providerId": "provider1",
  "amount": 75.0,
  "method": "creditCard",
  "status": "completed",
  "createdAt": "2024-06-10T15:30:00Z",
  "completedAt": "2024-06-10T15:32:00Z",
  "transactionId": "TXN123456789",
  "errorMessage": null
}
```

### Admins Collection

#### Document ID: `admin1`
```json
{
  "id": "admin1",
  "email": "admin@example.com",
  "role": "admin",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

## Test Accounts

### User Test Accounts
- Email: `alice@example.com` | Password: `password123`
- Email: `bob@example.com` | Password: `password123`
- Email: `carol@example.com` | Password: `password123`

### Provider Test Accounts
- Email: `expertplumber@example.com` | Password: `password123`
- Email: `electrician@example.com` | Password: `password123`
- Email: `mechanic@example.com` | Password: `password123`

### Admin Account
- Email: `admin@example.com` | Password: `admin123`

## Adding Data via Console

### Steps to Manually Add a Document:

1. Open Firebase Console
2. Select your ServiceHub project
3. Go to Firestore Database
4. Click on the collection (e.g., "users")
5. Click "Add document"
6. Enter the document ID (e.g., "user1")
7. Add fields one by one or paste JSON
8. Click "Save"

### Import via JSON:

Some fields like timestamps need special handling:
- For `createdAt`: Use "Timestamp" field type and set date
- For `scheduleTime`: Use "Timestamp" field type
- For numbers: Use "Number" field type
- For arrays: Use "Array" field type
- For objects: Use "Map" field type

## Running Seed Script

If using Node.js with Firebase Admin SDK:

```bash
npm install firebase-admin
# Create seed.js file
node seed.js
```

Example `seed.js`:
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedData() {
  try {
    // Add users
    await db.collection('users').doc('user1').set({
      id: 'user1',
      name: 'Alice Johnson',
      email: 'alice@example.com',
      // ... rest of fields
    });
    console.log('Data seeded successfully!');
  } catch (error) {
    console.error('Error seeding data:', error);
  }
}

seedData();
```

## Notes

- All timestamps are in ISO 8601 format
- Ratings are out of 5.0
- Currency is in USD ($)
- Sample images are empty strings (add real URLs later)
- Modify data as needed for your testing

---

Happy testing! 🎉
