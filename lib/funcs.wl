StringToBits[str_String] := Flatten[IntegerDigits[ToCharacterCode[str], 2, 8]];

BitsToString[bits_List] := FromCharacterCode[FromDigits[#, 2] & /@ Partition[bits, 8]];

(* Converte una lista di bit in una stringa Esadecimale *)
BitsToHex[bits_List] := StringJoin[
  IntegerString[FromDigits[#, 2], 16, 1] & /@ Partition[bits, 4]
];

(* Funzione Inversa: Converte una stringa Esadecimale in lista di bit *)
HexToBits[hex_String] := Flatten[
  IntegerDigits[FromDigits[#, 16], 2, 4] & /@ Characters[hex]
];
