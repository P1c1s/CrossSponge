Struct[key_List, iv_List] := Partition[Join[key, iv], Sqrt[Length[Join[key,iv]]]];

StringToBits[str_String] := Flatten[IntegerDigits[ToCharacterCode[str], 2, 8]];

BitsToString[bits_List] := FromCharacterCode[FromDigits[#, 2] & /@ Partition[bits, 8]];

SubstitutionLayer[state_List] := Module[
  {len, half, qTL, qTR, qBL, qBR, nTL, nTR, nBL, nBR},
  
  len = Length[state];
  half = len / 2;

  (* 1. Estrazione dei 4 quadranti originali *)
  qTL = state[[1 ;; half, 1 ;; half]];
  qTR = state[[1 ;; half, half + 1 ;; len]];
  qBL = state[[half + 1 ;; len, 1 ;; half]];
  qBR = state[[half + 1 ;; len, half + 1 ;; len]];

  (* 2. Calcolo dei nuovi quadranti con incrocio *)
  nTL = PolynomialMod[qTL + qTL * qBR, 2];
  nTR = PolynomialMod[qTR + qTR * qBL, 2];
  nBL = PolynomialMod[qBL + qBL * qTR, 2];
  nBR = PolynomialMod[qBR + qBR * qTL, 2];

  (* 3. Ricostruzione della matrice quadrata N x N originale *)
  ArrayFlatten[{{nTL, nTR}, {nBL, nBR}}]
]

DiffiusionLayer[state_List] := Module[
    {row1, row2, row3, row4, col1, col2, col3, col4, len},
    
    len = Length[state];
    {row1, row2, row3, row4} = state;

    (* Rotazioni orizzoantali *)
    row1 = RotateLeft[row1, 1]; 
    row2 = RotateLeft[row2, 2];
    row3 = RotateLeft[row3, 3];
    row4 = RotateLeft[row4, 4];

    (* Rotazioni verticali *)
    {col1, col2, col3, col4} = Transpose[{row1, row2, row3, row4}];  
    {RotateLeft[col1, len / 2], 
     RotateLeft[col2, len / 2],
     RotateLeft[col3, len / 2],
     RotateLeft[col4, len / 2]
    }

];

StateMask[state_List] := Module[
    {row1, row2, row3, row4},

    row1 = state[[1]];
    row2 = state[[2]];
    row3 = state[[3]];
    row4 = state[[4]];

    newRow1 = {row1[[1]], 0, row1[[3]], 0};
    newRow2 = {0,row2[[2]], 0, row2[[4]]};
    newRow3 = {row3[[1]], 0, row3[[3]], 0};
    newRow4 = {0, row4[[2]], 0, row4[[4]]};

    {newRow1, newRow2, newRow3, newRow4}

];

WordMask[word_List] := Module[
    {row1, row2, row3, row4},

    row1 = {word[[1]], 0, word[[2]], 0};
    row2 = {0, word[[3]], 0, word[[4]]};
    row3 = {word[[5]], 0, word[[6]], 0};
    row4 = {0, word[[7]], 0, word[[8]]};

    {row1, row2, row3, row4}
]

CipherMask[state_List] := {state[[1,1]], state[[1,3]], state[[2,2]], state[[2,4]], state[[3,1]], state[[3,3]], state[[4,2]], state[[4,4]]};

SpongeAbsorption[state_List, word_List] := PolynomialMod[WordMask[word] + state, 2]

CrossRound[state_List] := DiffiusionLayer[SubstitutionLayer[state]];

CrossSpongeWarmUp[key_List, iv_List, nRound_Integer] := Nest[CrossRound[#] &, Struct[key, iv], nRound];

CrossSpongeEnc[key_List, iv_List, nRound_Integer, word_List] := Module[
  {initState, absorbedState, cipherBits, nextState},
  initState = CrossSpongeWarmUp[key, iv, nRound];
  absorbedState = SpongeAbsorption[initState, word];
  cipherBits = CipherMask[absorbedState];
  nextState = CrossRound[absorbedState];
  cipherBits
];

CrossSpongeEncString[key_List, iv_List, nWarmRounds_Integer, str_String] := Module[
  {
    blocks = Partition[StringToBits[str], 8], (* Divide la stringa in blocchi da 8 bit *)
    state = CrossSpongeWarmUp[key, iv, nWarmRounds],
    absorbedState,
    cipherBlocks = {}
  },
  
  Do[
    (* 1. Assorbimento del blocco corrente *)
    absorbedState = SpongeAbsorption[state, block];
    
    (* 2. Estrazione degli 8 bit cifrati *)
    AppendTo[cipherBlocks, CipherMask[absorbedState]];
    
    (* 3. Permutazione per preparare lo stato al blocco successivo *)
    state = CrossRound[absorbedState];
    
  , {block, blocks}];
  
  (* Restituisce la lista di tutti i bit cifrati *)
  Flatten[cipherBlocks]
]

