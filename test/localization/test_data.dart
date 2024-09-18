// ignore_for_file: unnecessary_raw_strings

String getFileEn1Data() {
  return r'''
{
  "@@locale": "en",
  "keyA": "EN Value A",
  "@keyA": {
    "description": "Test description",
    "type": "text",
    "placeholders": {}
  },
  "keyB": "EN Value B",
  "@keyB": {
    "description": "Test description",
    "type": "text",
    "placeholders": {}
  },
  "keyC": "EN Value C with {param1} and {param2}",
  "@keyC": {
    "description": "Test description",
    "type": "text",
    "placeholders": {
      "param1": {
        "type": "int"
      },
      "totalPages": {
        "param2": "int"
      }
    }
  }
}

''';
}

String getFileEn2Data() {
  return r'''
{
  "@@locale": "en",
  "keyA": "EN Value A Other",
  "@keyA": {
    "description": "Test description",
    "type": "text",
    "placeholders": {}
  },
  "keyBOther": "EN Value B",
  "@keyB": {
    "description": "Test description",
    "type": "text",
    "placeholders": {}
  },
  "keyC": "EN Value C with {param1} and {param2}",
  "@keyC": {
    "description": "Test description",
    "type": "text",
    "placeholders": {
      "param1": {
        "type": "int"
      },
      "param2": {
        "type": "int"
      }
    }
  },
  "keyCOther": "EN Value C with {param1} and {param2}",
  "@keyCOther": {
    "description": "Test description",
    "type": "text",
    "placeholders": {
      "param1": {
        "type": "int"
      },
      "param2": {
        "type": "int"
      }
    }
  },
  "keyCOther2": "EN Value C with {param1} and {param3}",
  "@keyCOther2": {
    "description": "Test description",
    "type": "text",
    "placeholders": {
      "param1": {
        "type": "int"
      },
      "param3": {
        "type": "int"
      }
    }
  }
}

''';
}

String getFileUa1Data() {
  return r'''
{
  "@@locale": "ua",
  "keyA": "UA Value A",
  "@keyA": {
    "description": "Test description",
    "type": "text",
    "placeholders": {}
  },
  "keyCOther": "UA Value C with {param1} and {param2}",
  "@keyCOther": {
    "description": "Test description",
    "type": "text",
    "placeholders": {
      "param1": {
        "type": "int"
      },
      "totalPages": {
        "param2": "int"
      }
    }
  }
}

''';
}