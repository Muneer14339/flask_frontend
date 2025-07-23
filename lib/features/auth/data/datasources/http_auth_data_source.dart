import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

abstract class HttpAuthDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String fullName, String email, String password);
  Future<bool> forgotPassword(String email);
  Future<bool> verifyOtp(String email, String otp);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class HttpAuthDataSourceImpl implements HttpAuthDataSource {
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  // Store tokens for authenticated requests
  String? _accessToken;
  String? _refreshToken;

  HttpAuthDataSourceImpl({
    required Dio dio,
    required GoogleSignIn googleSignIn,
  }) : _dio = dio,
        _googleSignIn = googleSignIn {

    // Configure Dio base URL and interceptors
    _dio.options.baseUrl = 'http://192.168.1.248:5000/api'; // Replace with your backend URL
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        options.headers['Content-Type'] = 'application/json';
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh on 401 errors
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            await _refreshAccessToken();
            // Retry the original request
            final response = await _dio.request(
              error.requestOptions.path,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ),
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
            );
            handler.resolve(response);
          } catch (e) {
            // Refresh failed, clear tokens and redirect to login
            await signOut();
            handler.next(error);
          }
        } else {
          handler.next(error);
        }
      },
    ));
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign out from any previous sessions
      await _googleSignIn.signOut();

      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Send Google ID token to backend
      final response = await _dio.post('/auth/google-signin', data: {
        'googleToken': googleAuth.idToken,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          // Store tokens
          final tokens = responseData['data']['tokens'];
          _accessToken = tokens['access_token'];
          _refreshToken = tokens['refresh_token'];

          // Return user data
          return UserModel.fromJson(responseData['data']['user']);
        } else {
          throw Exception(responseData['message'] ?? 'Google sign-in failed');
        }
      } else {
        throw Exception('Google sign-in failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Google Sign-in Error: $e');
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          // Store tokens
          final tokens = responseData['data']['tokens'];
          _accessToken = tokens['access_token'];
          _refreshToken = tokens['refresh_token'];

          // Return user data
          return UserModel.fromJson(responseData['data']['user']);
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  @override
  Future<UserModel> signUp(String fullName, String email, String password) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          // Store tokens
          final tokens = responseData['data']['tokens'];
          _accessToken = tokens['access_token'];
          _refreshToken = tokens['refresh_token'];

          // Return user data
          return UserModel.fromJson(responseData['data']['user']);
        } else {
          throw Exception(responseData['message'] ?? 'Sign up failed');
        }
      } else {
        throw Exception('Sign up failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['success'] == true;
      } else {
        throw Exception('Forgot password failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  @override
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['success'] == true;
      } else {
        throw Exception('OTP verification failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // If we have an access token, notify the backend
      if (_accessToken != null) {
        try {
          await _dio.post('/auth/logout');
        } catch (e) {
          // Ignore logout errors, continue with local logout
        }
      }

      // Clear local tokens
      _accessToken = null;
      _refreshToken = null;

    } catch (e) {
      // Clear tokens even if sign out fails
      _accessToken = null;
      _refreshToken = null;
      throw Exception('Sign out Error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      if (_accessToken == null) return null;

      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          return UserModel.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) throw Exception('No refresh token available');

    final response = await _dio.post('/auth/refresh',
        options: Options(
            headers: {'Authorization': 'Bearer $_refreshToken'}
        )
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      if (responseData['success'] == true) {
        final tokens = responseData['data']['tokens'];
        _accessToken = tokens['access_token'];
      } else {
        throw Exception('Token refresh failed');
      }
    } else {
      throw Exception('Token refresh failed with status: ${response.statusCode}');
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.data != null) {
      final errorData = e.response!.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
        return errorData['message'];
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'Network error: ${e.message}';
    }
  }

  String? getToken() => _accessToken;
}