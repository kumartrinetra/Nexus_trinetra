

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_frontend/services/dioProvider.dart';

class AIRepository{
  final Dio dio;

  AIRepository(this.dio);

  Future<String?> getAIInsight() async
  {
    try{
      final response = await dio.get("");

      final data = response.data;

      return data["insight"];
    }
        on DioException catch(err)
    {
      print(err.response?.data);
      return null;
    }
  }


}

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  return AIRepository(ref.read(dioProvider));
});