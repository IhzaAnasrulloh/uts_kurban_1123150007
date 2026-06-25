class ApiConstants { 
  //static const String baseUrl = 'http://10.241.90.82:8080/v1';
  static const String baseUrl = 'http://192.168.1.8:8080/v1'; 
  
  // Auth endpoints 
  static const String verifyToken = '/auth/verify-token'; 
  
  // Product endpoints 
  static const String products = '/products'; 
  static const String cart = '/cart'; 
  
  // Timeout 
  static const int connectTimeout = 15000; 
  static const int receiveTimeout = 15000; 
}