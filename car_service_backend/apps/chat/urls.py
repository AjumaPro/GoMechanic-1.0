from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatRoomViewSet, MessageViewSet, TypingStatusViewSet

router = DefaultRouter()
router.register(r'rooms', ChatRoomViewSet, basename='chatroom')
router.register(r'messages', MessageViewSet, basename='message')
router.register(r'typing-status', TypingStatusViewSet, basename='typingstatus')

urlpatterns = [
    path('', include(router.urls)),
] 