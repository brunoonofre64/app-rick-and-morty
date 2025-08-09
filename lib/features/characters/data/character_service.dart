import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/paginated_response.dart';
import 'character_model.dart';

class CharacterService {
  CharacterService(this._client);
  final ApiClient _client;

  Future<PaginatedResponse<Character>> fetchCharacters({
    int page = 1,
    String? name,
    String? status,
    String? gender,
    String? species,
    String? type,
  }) async {
    final query = <String, dynamic>{'page': page};
    if (name?.isNotEmpty == true) query['name'] = name;
    if (status?.isNotEmpty == true) query['status'] = status;
    if (gender?.isNotEmpty == true) query['gender'] = gender;
    if (species?.isNotEmpty == true) query['species'] = species;
    if (type?.isNotEmpty == true) query['type'] = type;

    final res = await _client.get<Map<String, dynamic>>('/character', query: query);
    final data = res.data!;
    final info = PageInfo.fromJson(data['info']);
    final results = (data['results'] as List<dynamic>)
        .map((e) => Character.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedResponse(info: info, results: results);
  }

  Future<Character> fetchCharacter(int id) async {
    final res = await _client.get<Map<String, dynamic>>('/character/$id');
    return Character.fromJson(res.data!);
  }

  Future<List<Character>> fetchMultiple(List<int> ids) async {
    if (ids.isEmpty) return [];
    final res = await _client.get<dynamic>('/character/${ids.join(',')}');
    final d = res.data;
    if (d is List) return d.map((e) => Character.fromJson(e)).toList();
    return [Character.fromJson(d as Map<String, dynamic>)];
  }
}

final characterServiceProvider =
    Provider<CharacterService>((ref) => CharacterService(ref.read(apiClientProvider)));
