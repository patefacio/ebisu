library my_pub_package.self_contained;

import 'dart:convert' as convert;
import 'package:ebisu/ebisu.dart' as ebisu;

// custom <additional imports>
// end <additional imports>

/// An address composed of zip, street and street number
class Address {

  Address._default();

  String zip;
  String street;
  int streetNumber;

  // custom <class Address>
  // end <class Address>


  Map toJson() => {
      "zip": ebisu.toJson(zip),
      "street": ebisu.toJson(street),
      "streetNumber": ebisu.toJson(streetNumber),
  };

  static Address fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new Address._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    zip = jsonMap["zip"];
    street = jsonMap["street"];
    streetNumber = jsonMap["streetNumber"];
  }

}


class AddressBook {

  AddressBook._default();

  Map<String,Address> book = {};

  // custom <class AddressBook>
  // end <class AddressBook>


  Map toJson() => {
      "book": ebisu.toJson(book),
  };

  static AddressBook fromJson(Object json) {
    if(json == null) return null;
    if(json is String) {
      json = convert.JSON.decode(json);
    }
    assert(json is Map);
    return new AddressBook._default()
      .._fromJsonMapImpl(json);
  }

  void _fromJsonMapImpl(Map jsonMap) {
    // book is Map<String,Address>
    book = ebisu
      .constructMapFromJsonData(
        jsonMap["book"],
        (value) => Address.fromJson(value))
  ;
  }

}

// custom <library self_contained>
// end <library self_contained>


