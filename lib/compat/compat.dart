library graph.compat;

class CloneNotSupportedException extends Exception {
  factory CloneNotSupportedException([var msg=null]) //;// : super(msg);
  {
    return new Exception(msg);
  }
}

/*class NumberFormatException extends Exception {
  factory NumberFormatException([var msg=null])
  {
    return new Exception(msg);
  }
}*/