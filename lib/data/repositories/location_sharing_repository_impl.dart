import 'package:kumayokeru_app/data/datasources/local/auth_token_local_datasource.dart';
import 'package:kumayokeru_app/data/datasources/remote/location_sharing_remote_datasource.dart';
import 'package:kumayokeru_app/data/models/member_location_model.dart';
import 'package:kumayokeru_app/data/models/share_group_model.dart';
import 'package:kumayokeru_app/domain/entities/member_location.dart';
import 'package:kumayokeru_app/domain/entities/share_group.dart';
import 'package:kumayokeru_app/domain/repositories/location_sharing_repository.dart';

class LocationSharingRepositoryImpl implements LocationSharingRepository {
  LocationSharingRepositoryImpl({
    LocationSharingRemoteDataSource? remoteDataSource,
    AuthTokenLocalDataSource? tokenLocalDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? LocationSharingRemoteDataSource(),
       _tokenLocalDataSource =
           tokenLocalDataSource ?? AuthTokenLocalDataSource();

  final LocationSharingRemoteDataSource _remoteDataSource;
  final AuthTokenLocalDataSource _tokenLocalDataSource;

  @override
  Future<List<ShareGroup>> listGroups() async {
    final token = await _requireToken();
    final json = await _remoteDataSource.listGroups(token);
    return json.map((e) => ShareGroupModel.fromJson(e).toEntity()).toList();
  }

  @override
  Future<ShareGroup> createGroup(String name) async {
    final token = await _requireToken();
    final json = await _remoteDataSource.createGroup(token, name);
    return ShareGroupModel.fromJson(json).toEntity();
  }

  @override
  Future<void> inviteMember(String groupId, String email) async {
    final token = await _requireToken();
    await _remoteDataSource.inviteMember(token, groupId, email);
  }

  @override
  Future<void> postLocation({required double lat, required double lng}) async {
    final token = await _requireToken();
    await _remoteDataSource.postLocation(token, lat: lat, lng: lng);
  }

  @override
  Future<List<MemberLocation>> pollLocations(String groupId) async {
    final token = await _requireToken();
    final json = await _remoteDataSource.pollLocations(token, groupId);
    return json.map((e) => MemberLocationModel.fromJson(e).toEntity()).toList();
  }

  Future<String> _requireToken() async {
    final token = await _tokenLocalDataSource.readToken();
    if (token == null) {
      throw LocationSharingApiException('ログインが必要です');
    }
    return token;
  }
}
