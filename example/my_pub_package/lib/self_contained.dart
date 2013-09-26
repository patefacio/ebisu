library self_contained;

import 'package:ebisu/ebisu_utils.dart' as ebisu_utils;
// custom <additional imports>
// end <additional imports>


/// An address composed of zip, street and street number
class Address {
  String zip;
  String street;
  int streetNumber;

  // custom <class Address>
  // end <class Address>

  Map toJson() {
    return {
    "zip": ebisu_utils.toJson(zip),
    "street": ebisu_utils.toJson(street),
    "streetNumber": ebisu_utils.toJson(streetNumber),
    };
  }

  static Address fromJson(String json) {
    Map jsonMap = convert.JSON.decode(json);
    Address result = new Address();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static Address fromJsonMap(Map jsonMap) {
    Address result = new Address();
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
  Map<String,Address> book = {};

  // custom <class AddressBook>
  // end <class AddressBook>

  Map toJson() {
    return {
    "book": ebisu_utils.toJson(book),
    };
  }

  static AddressBook fromJson(String json) {
    Map jsonMap = convert.JSON.decode(json);
    AddressBook result = new AddressBook();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  static AddressBook fromJsonMap(Map jsonMap) {
    AddressBook result = new AddressBook();
    result._fromJsonMapImpl(jsonMap);
    return result;
  }

  void _fromJsonMapImpl(Map jsonMap) {
    // book map of <String, Address>
    book = { };
    jsonMap["book"].forEach((k,v) {
      book[k] = Address.fromJsonMap(v);
    });
  }
}

// custom <library self_contained>
// end <library self_contained>

