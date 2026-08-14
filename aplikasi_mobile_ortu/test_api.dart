import 'package:dio/dio.dart';

void main() async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://127.0.0.1:8080/api/v1',
    ));
    
    // We need to login to get a token
    final loginRes = await dio.post('/users/login', data: {
      'identifier': '001735759174', // Try to login as parent Achmad Bilzan
      'password': 'password123',
    });
    
    final token = loginRes.data['token'];
    print("Logged in, token: \$token");
    
    dio.options.headers['Authorization'] = 'Bearer \$token';
    
    print("Testing /users/children...");
    final childRes = await dio.get('/users/children');
    print(childRes.data);
    
    print("Testing /dashboard/summary?child_id=...");
    final children = childRes.data['data'] as List;
    if (children != null && children.isNotEmpty) {
      final childId = children[0]['id'];
      final summaryRes = await dio.get('/dashboard/summary', queryParameters: {'child_id': childId});
      print(summaryRes.data);
    }
  } catch (e) {
    if (e is DioException) {
      print("DioError: ${e.response?.statusCode} - ${e.response?.data}");
      print(e.message);
    } else {
      print(e);
    }
  }
}
