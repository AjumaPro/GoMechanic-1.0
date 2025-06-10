from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import MechanicProfile

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 
                 'phone_number', 'address', 'profile_picture', 'user_type', 
                 'is_verified', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class UserRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'confirm_password', 
                 'first_name', 'last_name', 'phone_number', 'address', 
                 'user_type')

    def validate(self, data):
        if data['password'] != data['confirm_password']:
            raise serializers.ValidationError("Passwords don't match")
        return data

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        user = User.objects.create_user(**validated_data)
        return user

class MechanicProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = MechanicProfile
        fields = ('id', 'user', 'expertise', 'years_of_experience', 
                 'is_available', 'current_location', 'rating', 'total_jobs', 
                 'documents', 'created_at', 'updated_at')
        read_only_fields = ('id', 'rating', 'total_jobs', 'created_at', 'updated_at') 