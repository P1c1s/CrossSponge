Struct[key_List, iv_List] := Partition[Join[key, iv], Sqrt[Length[Join[key,iv]]]]

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
    {row1, row2, row3, row4, len},
    
    row1 = state[[1]];
    row2 = state[[2]];
    row3 = state[[3]];
    row4 = state[[4]];
    len = Length[state];

    {RotateLeft[row1, len / 2], 
     RotateLeft[row2, len / 2],
     RotateLeft[row3, len / 2],
     RotateLeft[row4, len / 2]
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

Sponge[state_List, word_List] := Mod[StateMask[state] + WordMask[word] + state, 2]

CrossRound[state_List] := DiffiusionLayer[SubstitutionLayer[state]];

CrossSpongeWarmUp[key_List, iv_List, nRound_Integer] := Nest[CrossRound[#] &, Struct[key, iv], nRound];