import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:memob/NotesClass.dart';
import 'package:memob/meetingClass.dart';
import 'package:memob/utilities.dart' as utilities;

var api = new API_Service();

class API_Service {

  String userTokenq;
  String baseurl;

  API_Service(){
    Future<String> token = utilities.getTokenData();
    token.then((value) {
      if (value != null) {
        this.userTokenq = value;
//        print('p'+userTokenq);
      } else {
        utilities.showLongToast(value);

      }
    });
    baseurl='https://app.meetnotes.co/';
  }
  getAllActions() async {
    var response = await http.get(
        Uri.encodeFull( baseurl+'api/v1/action-items/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getUser() async {
    var response = await http.get(
        Uri.encodeFull( baseurl + 'api/v2/settings/account/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getRecentNotesDetails() async {
    var response = await http.get(
        Uri.encodeFull( baseurl + 'api/v2/recent-notes/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getOpenActions() async {
    var response = await http.get(
        Uri.encodeFull(
            baseurl + 'api/v1/action-items/?status__in=pending,doing'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getRecentlyUpdatedActions() async {
    var response = await http.get(
        Uri.encodeFull( baseurl +
            'api/v1/action-items/?ordering=-updated_at'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getRecentlyClosedActions() async {
    var response = await http.get(
        Uri.encodeFull(
          baseurl +
            'api/v1/action-items/?ordering=-updated_at&status=done'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getAllTeams(String userToken1) async {
    var response = await http.get(
        Uri.encodeFull( baseurl + 'api/v2/teams/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userToken1,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  getTeamMembersDetails() async {
    var response = await http.get(
        Uri.encodeFull( baseurl + 'api/v2/teams/detail/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache',
          HttpHeaders.cookieHeader:
              'sessionid=hqzl74coesky2o60rj58vwv618v7h8kn;'
        });
    return response;
  }

  getMeeting(String userToken) async {
    var response = await http.get(
        Uri.encodeFull(baseurl + 'api/v2/meetings/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userToken,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache',
        });
    return response;
  }
  choiceAction(String uuid){
    return (baseurl + 'api/v2/action-item/' +
        uuid +
        '/command/update/');
  }
  getRecentNotes(String q) async{
    var response = await http.get(
        Uri.encodeFull(
            baseurl + 'api/v2/meeting-data/'+q),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;

  }
  getRecentNotesCount(String token,String eventId) async{
    var response = await http.get(
        Uri.encodeFull(
           baseurl + 'api/v2/attachments/?event=' + eventId),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + token,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  fetchUserData() async{
    var response = await http.get(
        Uri.encodeFull( baseurl + 'api/v2/settings/account/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token '+userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        });
    return response;
  }

  settingsUpdate(Map body) async{
    var data = json.encode(body);
    var response =
    await http.post(baseurl + 'api/v2/settings/account/',
        headers: {
          HttpHeaders.authorizationHeader: 'Token '+userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        },
        body: data);
    return response;
  }

  addAliases(Map body) async{
    var data = json.encode(body);
    var response =
    await http.post(baseurl + 'api/v2/user/alias/',
        headers: {
          HttpHeaders.authorizationHeader: 'Token '+userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache'
        },
        body: data);
    return response;
  }

  inviteMember(Map body) async{
    var data = json.encode(body);
    var response = await http.post('',
        headers: {
          HttpHeaders.authorizationHeader: 'Token '+userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache',
          HttpHeaders.cookieHeader:
          'sessionid=hqzl74coesky2o60rj58vwv618v7h8kn; csrftoken=Rc56oTojXV1N3cKEdV1ImYXxOTfb4pVi;',
          HttpHeaders.refererHeader:
          'https://app.meetnotes.co/settings/teams/members/'
        },
        body: data);
    return response;
  }

  getAliases() async {
    var response = await http.get(
        Uri.encodeFull(baseurl + 'api/v2/user/alias/'),
        headers: {
          HttpHeaders.authorizationHeader: 'Token ' + userTokenq,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.cacheControlHeader: 'no-cache',
        });
    return response;
  }

  postData(String data){
    return ( baseurl + "api/v2/meeting/" + data + "/share/");
  }


}
