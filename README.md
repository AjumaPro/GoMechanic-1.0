# Car Maintenance & Towing App

A comprehensive solution for car maintenance and towing services, built with Django REST API backend and Flutter mobile apps.

## Project Structure

- `car_service_backend/` - Django REST API backend
- `car_owner_app/` - Flutter app for car owners
- `mechanic_app/` - Flutter app for mechanics/service providers

## Backend Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
Create a `.env` file in the root directory with:
```
DEBUG=True
SECRET_KEY=your-secret-key
DATABASE_URL=your-database-url
FIREBASE_CREDENTIALS=path-to-firebase-credentials.json
```

4. Run migrations:
```bash
python manage.py migrate
```

5. Create superuser:
```bash
python manage.py createsuperuser
```

6. Run development server:
```bash
python manage.py runserver
```

## Frontend Setup

### Car Owner App
1. Navigate to `car_owner_app/`
2. Run `flutter pub get`
3. Configure Firebase
4. Run the app: `flutter run`

### Mechanic App
1. Navigate to `mechanic_app/`
2. Run `flutter pub get`
3. Configure Firebase
4. Run the app: `flutter run`

## Features

- User authentication and profile management
- Vehicle registration and management
- Service booking and tracking
- Real-time mechanic location tracking
- In-app chat
- Payment processing
- Push notifications
- Service history and ratings

## API Documentation

API documentation is available at `/api/docs/` when running the development server.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request 