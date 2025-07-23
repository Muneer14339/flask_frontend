import 'package:dio/dio.dart';
import '../model/user_model.dart';


abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String fullName, String email, String password);
  Future<bool> forgotPassword(String email);
  Future<bool> verifyOtp(String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> signUp(String fullName, String email, String password) async {
    final response = await dio.post('/auth/signup', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });

    return UserModel.fromJson(response.data);
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await dio.post('/auth/forgot-password', data: {
      'email': email,
    });

    return response.statusCode == 200;
  }

  @override
  Future<bool> verifyOtp(String otp) async {
    final response = await dio.post('/auth/verify-otp', data: {
      'otp': otp,
    });

    return response.statusCode == 200;
  }
}