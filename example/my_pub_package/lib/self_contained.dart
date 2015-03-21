library self_contained;

import 'dart:convert' as convert;
import 'package:ebisu/ebisu.dart' as ebisu;
// custom <additional imports>
// end <additional imports>


/// An address composed of zip, street and street number
class Address {

  Address._json();

  String zip;
  String street;
  int streetNumber;

  // custom <class Address>
  // end <class Address>

  Map toJson() {
    return {
    "zip": ebisu.toJson(zip),
    "street": ebisu.toJson(street),
    "streetNumber": ebisu.toJson(streetNumber),
    };
  }

  static Address fromJson(String json) {
    if(json == null) return null;
    Map jsonMap = convert.JSON.decode(json);
    Address result = new Address._json();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static Address fromJsonMap(Map jsonMap) {
    if(jsonMap == null) return null;
    Address result = new Address._json();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {
    zip = jsonMap["zip"];
    street = jsonMap["street"];
    streetNumber = jsonMap["streetNumber"];
  }

}

class AddressBook {

  AddressBook._json();

  Map<String,Address> book = {};

  // custom <class AddressBook>
  // end <class AddressBook>

  Map toJson() {
    return {
    "book": ebisu.toJson(book),
    };
  }

  static AddressBook fromJson(String json) {
    if(json == null) return null;
    Map jsonMap = convert.JSON.decode(json);
    AddressBook result = new AddressBook._json();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static AddressBook fromJsonMap(Map jsonMap) {
    if(jsonMap == null) return null;
    AddressBook result = new AddressBook._json();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {

    // book is Map<String,Address>
    book = {};
    jsonMap["book"].forEach((k,v) {
      book[
        k
      ] = (v is Map)?
      Address.fromJsonMap(v) :
      Address.fromJson(v);
    });
  }

}

// custom <library self_contained>
// end <library self_contained>
