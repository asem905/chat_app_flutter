# Chat Application - Architecture Documentation

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture Overview](#architecture-overview)
- [WebSocket System](#websocket-system)
- [Stream Listeners](#stream-listeners)
- [State Management with Cubit](#state-management-with-cubit)
- [Caching Strategy](#caching-strategy)
- [Idempotency Tokens](#idempotency-tokens)
- [SOLID Principles](#solid-principles)
- [Design Patterns](#design-patterns)

---

## 🎯 Overview

A real-time chat application built with Flutter and Node.js that works both online and offline. Messages are cached locally and automatically synced when the connection is restored.

### Key Features
- ✅ Real-time messaging using WebSockets
- ✅ Works offline with local database
- ✅ Prevents duplicate messages
- ✅ Auto-syncs pending messages when back online
- ✅ Clean, organized code structure
- ✅ Professional architecture patterns

---

## 🏗️ Architecture Overview

### Project Structure

The app is organized by features, not by file types:

```
lib/
├── core/                    # Shared components
│   ├── database/           # SQLite database
│   ├── di/                 # Dependency injection
│   ├── networking/         # API & WebSocket
│   ├── services/           # Shared services
│   └── widgets/            # Reusable UI
│
└── features/               # App features
    ├── chat_room/          # Chat functionality
    ├── home/               # Home screen
    ├── login/              # Authentication
    └── signup/             # User registration
```

### Three-Layer Architecture

Each feature follows a clean 3-layer structure:

**1. Data Layer** - Where data comes from
   - Models: Data structures
   - Services: API calls
   - Repositories: Combines cache + network

**2. Logic Layer** - Business rules
   - Cubits: State management
   - States: All possible app states

**3. View Layer** - What users see
   - Screens: Full pages
   - Widgets: Reusable components

---

## 🔌 WebSocket System

### What Are WebSockets?

WebSockets create a permanent, two-way connection between your app and the server. Unlike regular HTTP requests (you ask, server answers), WebSockets let the server send you data anytime something happens.

### How It Works in This App

**WebSocketService** manages the real-time connection:

1. **Connects to server** with user authentication
2. **Joins chat rooms** to receive room-specific messages
3. **Listens for events** like new messages or typing indicators
4. **Broadcasts events** to the app using streams

### Socket Events

**Events We Listen For:**
- `connect` - Connection established
- `disconnect` - Connection lost
- `newMessage` - Someone sent a message
- `userTyping` - Someone started typing
- `userStoppedTyping` - Someone stopped typing
- `error` - Something went wrong

**Events We Send:**
- `joinRoom` - Join a chat room
- `leaveRoom` - Leave a chat room
- `typing` - Let others know you're typing
- `stopTyping` - Let others know you stopped

### Connection Flow

```
App starts → Get auth token → Connect to server → Join room → Listen for messages
```

When a message arrives:
```
Server sends → WebSocket receives → Parse message → Add to stream → UI updates
```

---

## 📡 Stream Listeners

### What Are Streams?

Think of streams as rivers of data. Instead of asking "do I have new messages?" repeatedly, you subscribe to a stream and get notified whenever new messages flow through.

### Three Types of Streams Used

**1. WebSocket Streams** - Real-time events from server
   - New messages stream
   - Typing indicators stream
   - Connection status stream

**2. Connectivity Streams** - Internet connection status
   - Monitors if device is online/offline
   - Triggers sync when connection restored

**3. BLoC Streams** - App state changes
   - Message list updates
   - Loading states
   - Error states

### Why Streams Are Great

✅ **Reactive** - UI updates automatically when data changes  
✅ **Efficient** - Only rebuilds what needs to update  
✅ **Clean** - Separates data flow from UI logic  

### Lifecycle Management

All streams are properly closed when not needed to prevent memory leaks. When you leave a chat room, all subscriptions are cancelled.

---

## 🎛️ State Management with Cubit

### What is Cubit?

Cubit is a simplified version of BLoC (Business Logic Component). It manages your app's state and tells the UI when to update.

### How It Works

1. **Cubit** holds the current state
2. Something happens (user sends message)
3. Cubit processes it (send to server)
4. Cubit emits new state (message sent)
5. UI listens and rebuilds automatically

### 17 Different States

The app uses specific states for each situation:

**Loading States**
- `ChatRoomInitial` - Starting point
- `ChatRoomLoading` - Loading messages
- `ChatRoomLoadingMore` - Loading older messages

**Success States**
- `ChatRoomLoaded` - Messages displayed (tracks: messages, typing users, offline status)
- `MessageSent` - Message sent successfully
- `MessageEdited` - Message edited successfully
- `MessageDeleted` - Message deleted successfully

**Progress States**
- `MessageSending` - Sending message...
- `MessageEditing` - Editing message...
- `MessageDeleting` - Deleting message...
- `MessageQueued` - Message saved for later (offline)

**Error States**
- `ChatRoomError` - General error
- `MessageSendError` - Failed to send
- `DuplicateMessage` - Message already sent

**Real-time States**
- `UserTyping` - Someone is typing
- `UserStoppedTyping` - Typing stopped

### Benefits of Using States

✅ Predictable - Always know what state the app is in  
✅ Debuggable - Can track state changes  
✅ Testable - Easy to test each state  
✅ Maintainable - Clear separation of concerns  

---

## 💾 Caching Strategy

### Offline-First Approach

The app works like this:

1. **Try cache first** - Show data from local database instantly
2. **Fetch from server** - Get fresh data in background
3. **Update cache** - Save new data locally
4. **Stay in sync** - Keep cache and server aligned

### SQLite Database (3 Tables)

**Messages Table** - Stores all chat messages
- Message content, sender, timestamps
- Flags: is_sent, is_deleted, is_edited, is_pending
- Local ID for pending messages

**Pending Messages Table** - Queue for offline messages
- Messages waiting to be sent
- Retry counter (gives up after 5 attempts)
- Automatically cleared when sent successfully

**Rooms Table** - Chat room information
- Room details and unread counts
- Last sync timestamp
- Indexed for fast queries

### Database Optimizations

**Performance Indexes** - Speed up common queries:
- Index on `room_id` for fast message filtering
- Index on `created_at` for chronological sorting
- Index on `createdAt` for room ordering

**Batch Operations** - Insert multiple messages at once instead of one by one

### How Caching Works

**When Online:**
```
User opens chat → Load from cache (instant) → Fetch from server → Update cache → Refresh UI
```

**When Offline:**
```
User sends message → Save to pending table → Show with "pending" indicator → Wait for connection
```

**When Reconnected:**
```
Connection restored → Load pending messages → Send each to server → Remove from queue → Update UI
```

### Pending Message Retry Logic

1. Message fails to send
2. Add to pending queue with retry count = 0
3. When online, try to send
4. If fails, increment retry count
5. After 5 failed attempts, remove from queue

---

## 🛡️ Idempotency Tokens

### The Problem

Without idempotency tokens:
- User taps "Send" twice → Two identical messages
- Network retry → Duplicate message
- Offline sync → Multiple copies

### The Solution

Every message gets a unique token (like a fingerprint) based on:
- Message content
- Room ID
- Timestamp (to the second)

These three things are hashed using SHA256 to create a unique identifier.

### How It Prevents Duplicates

**Step 1:** User sends message "Hello"  
**Step 2:** App generates token: `abc123def456...`  
**Step 3:** Sends to server with token in header  
**Step 4:** Server checks: "Have I seen token `abc123def456` before?"  
  - **If NO:** Process message, save token to cache, return success
  - **If YES:** Ignore request, return "409 Conflict"  
**Step 5:** App receives response:
  - **200/201:** Success! Show message
  - **409:** Already processed, don't show duplicate

### Benefits

✅ Safe retries - Can retry without creating duplicates  
✅ Fast clicks - Double-tap send button won't duplicate  
✅ Offline sync - Pending messages won't duplicate when synced  
✅ Network errors - Automatic retries are safe  

---

## 🎯 SOLID Principles

SOLID makes code easier to maintain, test, and extend. Here's how this app uses each principle:

### 1. Single Responsibility Principle (SRP)
**"Each class should do ONE thing only"**

✅ `ChatRoomService` - Only handles HTTP requests  
✅ `WebSocketService` - Only handles WebSocket connections  
✅ `ChatDatabase` - Only handles database operations  
✅ `ChatRoomCubit` - Only handles business logic  

**Why it matters:** If you need to change how HTTP works, you only touch `ChatRoomService`, not the entire app.

### 2. Open/Closed Principle (OCP)
**"Open for extension, closed for modification"**

✅ Base `ChatRoomState` class is never modified  
✅ New states extend the base without changing it  
✅ Can add `MessageReacting` state without touching existing states  

**Why it matters:** Add new features without breaking existing code.

### 3. Liskov Substitution Principle (LSP)
**"Subtypes must be usable in place of their base types"**

✅ Any `ChatRoomState` can be used where the base type is expected  
✅ `ChatRoomLoaded` and `ChatRoomError` are both valid `ChatRoomState` types  

**Why it matters:** Polymorphism works correctly, making code flexible.

### 4. Interface Segregation Principle (ISP)
**"Don't force classes to depend on methods they don't use"**

✅ WebSocket service only exposes streams, not internal methods  
✅ Repository exposes data methods, not HTTP details  
✅ Cubit depends only on repository interface, not implementation  

**Why it matters:** Less coupling, easier to change implementation.

### 5. Dependency Inversion Principle (DIP)
**"Depend on abstractions, not concrete implementations"**

✅ Cubit depends on `ChatRepositoryWithCache` (abstraction)  
✅ Not tied to specific database or API implementation  
✅ Can swap SQLite for Hive without changing Cubit  

**Why it matters:** Easy to test with mocks, swap implementations.

---

## 🎨 Design Patterns

Professional patterns used throughout the app:

### 1. Singleton Pattern
**"Only one instance should exist"**

**Used for:**
- Database connection (ChatDatabase.instance)
- Shared services

**Why:** Ensures single database connection, saves resources, maintains consistency.

---

### 2. Repository Pattern
**"Hide data source complexity"**

**What it does:**
- Hides whether data comes from cache or network
- Decides when to use cache vs server
- Manages sync between the two

**Benefits:**
- UI doesn't know or care where data comes from
- Easy to test with fake data
- Can change data source without affecting UI

---

### 3. BLoC/Cubit Pattern
**"Separate business logic from UI"**

**How it works:**
- Cubit handles all business logic
- UI just displays current state
- State changes trigger UI updates automatically

**Benefits:**
- Testable business logic
- Reusable logic across different UIs
- Clear separation of concerns

---

### 4. Factory Pattern
**"Create objects in a centralized way"**

**Used in:** Dependency Injection

**How it works:**
- `getIt.registerFactory` creates new instances each time
- `getIt.registerLazySingleton` creates one shared instance
- Dependencies are automatically injected

**Benefits:**
- Centralized object creation
- Easy to swap implementations
- Simplified testing with mocks

---

### 5. Observer Pattern
**"Notify interested parties about changes"**

**Used everywhere:**
- Streams notify listeners of new data
- BLoC notifies UI of state changes
- WebSocket notifies app of server events

**Benefits:**
- Loose coupling
- Reactive updates
- Multiple observers can listen

---

### 6. Strategy Pattern
**"Choose algorithm at runtime"**

**Example:** Cache strategy
- Online: Fetch from server, update cache
- Offline: Use cache only
- Strategy chosen based on connectivity

**Benefits:**
- Flexible behavior
- Easy to add new strategies
- Runtime decisions

---

### 7. State Pattern
**"Behavior changes based on current state"**

**How:** Different UI for each state
- Loading state → Show spinner
- Loaded state → Show messages
- Error state → Show error message

**Benefits:**
- Clear state transitions
- Predictable behavior
- Easy to debug

---

### 8. Dependency Injection Pattern
**"Provide dependencies from outside"**

**Using:** GetIt service locator

**How it works:**
- Services registered at app startup
- Components request dependencies instead of creating them
- Easy to inject mocks for testing

**Benefits:**
- Loose coupling
- Testability
- Single source of truth for dependencies

---

## 📊 Summary

### Architecture Highlights

✅ **Clean Architecture** - Organized in layers with clear responsibilities  
✅ **Feature-Based Structure** - Related code grouped together  
✅ **Offline-First** - Works without internet, syncs when available  
✅ **Real-Time** - Instant message delivery via WebSockets  
✅ **Robust State Management** - 17 states cover all scenarios  
✅ **No Duplicates** - Idempotency tokens prevent duplicate messages  
✅ **Performance Optimized** - Indexed queries, batch operations, selective rebuilds  
✅ **SOLID Principles** - Maintainable, testable, extensible  
✅ **Professional Patterns** - Industry-standard design patterns  

---

## 🛠️ Technologies

**Frontend (Flutter)**
- flutter_bloc - State management
- equatable - Value comparison
- get_it - Dependency injection
- sqflite - Local database
- socket_io_client - WebSocket
- http - REST API
- connectivity_plus - Network status

**Backend (Node.js)**
- Express.js - Web framework
- Socket.io - WebSocket server
- Sequelize - Database ORM
- JWT - Authentication

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.x or higher
- Node.js 16 or higher
- Dart 3.x or higher

### Installation

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Configure API endpoint:
Update `lib/core/networking/api_constants.dart` with your server URL

3. Run the app:
```bash
flutter run
```

---

## 📝 License

MIT License

---

**Built using Flutter and Clean Architecture**
