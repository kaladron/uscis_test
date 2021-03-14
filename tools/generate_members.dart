import 'dart:io';

import 'package:xml/xml.dart';

void main() {
  final file = File('MemberData.xml');
  final document = XmlDocument.parse(file.readAsStringSync());

  for (var member in document.findAllElements('member')) {
    var stateDistrictNode = member.findElements('statedistrict').first;
    print(stateDistrictNode.innerText);
    var memberInfoNode = member.findElements('member-info').first;
    print(memberInfoNode.findElements('firstname').first.innerText +
        ' ' +
        memberInfoNode.findElements('lastname').first.innerText);
  }

  // MemberData -> members -> member
  //   statedistrict
  //   member-info
  //     lastname
  //     firstname
  //     middlename
}
