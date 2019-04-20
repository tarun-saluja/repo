import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

Future<dynamic> uploadAttachment(
    String token, String filepath, String meetingId) async {
  File file = new File(filepath);
  String fileName = Path.basename(file.path);

  String url = "https://app.meetnotes.co/api/v2/meeting/$meetingId/attachment/";
  Map body = {
    'filename': fileName,
  };
  var bytes = file.readAsBytesSync();

  return http.post(
    url,
    body: body,
    headers: {
      HttpHeaders.authorizationHeader: "Token $token",
      HttpHeaders.acceptHeader: "application/json, text/plain, */*"
    },
  ).then((http.Response response) {
    final String res = response.body;
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    } else {
      _postRequest(response, bytes);
    }

    return json.decode(res);
  });
}

_postRequest(response, bytes) async {
  http.put(
    json.decode(response.body)['url'],
    body: bytes,
    headers: {
      HttpHeaders.contentTypeHeader: "binary/octet-stream",
      HttpHeaders.acceptHeader: "application/json, text/plain, */*"
    },
  ).then((http.Response responsePost) {
    if (responsePost.statusCode == 200) {
      _changeStatus(response);
    }
  });
}

_changeStatus(responsePost) async {
  String url =
      "https://app.meetnotes.co/api/v2/attachments/${json.decode(responsePost.body)['attachment_uuid']}/";
  return http.patch(
    url,
    body: json.encode({
      "upload_status": "UPLOAD_COMPLETED",
    }),
    headers: {
      HttpHeaders.authorizationHeader:
          "Token 74290f9175b0816113ee9b18d1b1a19ff120a313",
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.acceptHeader: "application/json"
    },
  ).then((http.Response response) {
    print('response, ${response.body}');
    print("Status Change   ${response.statusCode} ");
  });
}
