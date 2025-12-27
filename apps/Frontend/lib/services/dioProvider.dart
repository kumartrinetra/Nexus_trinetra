

import 'package:dio/dio.dart';
import 'package:nexus_frontend/services/tokenStorage.dart';
import 'package:riverpod/riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: "http://10.242.158.75:3000/api/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10)
    )
  );


  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await tokenStorage.getAccessToken();


      if(token != null)
        {
          options.headers["Authorization"] = "Bearer $token";
        }

      handler.next(options);
    },

    onError: (error, handler) async {
      if(error.response?.statusCode == 401)
        {
          final refreshToken = await tokenStorage.getRefreshToken();

          if(refreshToken == null)
            {
              await tokenStorage.clear();
              return handler.reject(error);
            }

          try{
            final response = await dio.post("auth/refresh", options: Options(headers: {
              "Authorization" : "Bearer $refreshToken"
            }));

            final newAccessToken = response.data["accessToken"];
            await tokenStorage.saveAccessToken(newAccessToken);

            final requestOptions = error.requestOptions;

            requestOptions.headers["Authorization"] = "Bearer $newAccessToken";

            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          } catch(_)
      {
        await tokenStorage.clear();
      }
        }

      handler.next(error);
    }
  ));

  return dio;
});