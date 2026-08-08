(* 1. Costruttori di base parametrizzati su n *)
Struct[key_List, iv_List] := 
  Partition[Join[key, iv], Sqrt[Length[Join[key, iv]]]];

(* Matrice di costanti affini 2D per il quadrante (n/2 x n/2) *)
AffineConstant[half_Integer] := Array[Mod[#1 + #2, 2] &, {half, half}];

(* 2. Layer algebrici parametrici *)
SubstitutionLayer[state_List] := Module[
  {n, half, qTL, qTR, qBL, qBR, nTL, nTR, nBL, nBR, AC},
  
  n = Length[state];
  half = n / 2;
  AC = AffineConstant[half];

  qTL = state[[1 ;; half, 1 ;; half]];
  qTR = state[[1 ;; half, half + 1 ;; n]];
  qBL = state[[half + 1 ;; n, 1 ;; half]];
  qBR = state[[half + 1 ;; n, half + 1 ;; n]];

  nTL = PolynomialMod[qTL + qTL * qBR + AC, 2];
  nTR = PolynomialMod[qTR + qTR * qBL + AC, 2];
  nBL = PolynomialMod[qBL + qBL * qTR + AC, 2];
  nBR = PolynomialMod[qBR + qBR * qTL + AC, 2];

  ArrayFlatten[{{nTL, nTR}, {nBL, nBR}}]
];

DiffiusionLayer[state_List] := Module[
  {n, shiftedRows, cols},
  n = Length[state];
  
  (* Rotazioni orizzoantali *)
  shiftedRows = MapIndexed[RotateRight[#1, #2[[1]]] &, state];
  
  (* Rotazioni verticali *)
  cols = Transpose[shiftedRows];
  MapIndexed[RotateRight[#1, Mod[#2[[1]] + n/2, n] + 1] &, cols]
];

CrossRound[state_List, round_Integer: 1] := Module[{n = Length[state]},
  PolynomialMod[DiffiusionLayer[SubstitutionLayer[state]], 2]
];

CrossSpongeWarmUp[key_List, iv_List, nRound_Integer] := 
  Fold[CrossRound[#1, #2] &, Struct[key, iv], Range[nRound]];

(* 3. Assorbimento ed Estrazione Dinamica per qTL *)

(* Estrae i bit da qTL *)
CipherMask[state_List] := Module[{half = Length[state] / 2},
  Flatten[state[[1 ;; half, 1 ;; half]]]
];

(* Assorbe un blocco di bit (lungo n^2 / 4) facendone lo XOR unicamente su qTL *)
SpongeAbsorption[state_List, wordBlock_List] := Module[
  {n, half, qTLMatrix, newState},
  
  n = Length[state];
  half = n / 2;
  
  (* Mappa i bit di input nella matrice (half x half) corrispondente a qTL *)
  qTLMatrix = Partition[wordBlock, half];
  
  newState = state;
  newState[[1 ;; half, 1 ;; half]] = 
    PolynomialMod[state[[1 ;; half, 1 ;; half]] + qTLMatrix, 2];
  
  newState
];

(* 4. Cifratura parametrica di una Stringa intera *)
CrossSpongeEncString[key_List, iv_List, nWarmRounds_Integer, str_String] := Module[
  {
    n = Sqrt[Length[key] + Length[iv]],
    rateBits, allBits, blocks, state, absorbedState, cipherBlocks = {}, roundCtr
  },
  
  (* Dimensione dinamica di qTL in bit: (n/2) * (n/2) = n^2 / 4 *)
  rateBits = (n / 2)^2;
  
  (* Converte la stringa in bit e applica il padding per dividere in blocchi esatti da rateBits *)
  allBits = StringToBits[str];
  blocks = Partition[allBits, rateBits, rateBits, 1, 0];
  
  state = CrossSpongeWarmUp[key, iv, nWarmRounds];
  roundCtr = nWarmRounds + 1;

  Do[
    (* 1. XOR del blocco corrente su qTL *)
    absorbedState = SpongeAbsorption[state, block];
    
    (* 2. Estrazione dei bit cifrati da qTL *)
    AppendTo[cipherBlocks, CipherMask[absorbedState]];
    
    (* 3. Permutazione dello stato per il blocco successivo *)
    state = CrossRound[absorbedState, roundCtr];
    roundCtr++;
  , {block, blocks}];

  Flatten[cipherBlocks]
];


(* Decifratura di un singolo blocco e aggiornamento dello stato *)
CrossSpongeDecBlock[state_List, cipherBlock_List] := Module[
  {half, currentTL, plainBlock, newState},
  
  half = Length[state] / 2;
  currentTL = CipherMask[state];
  
  (* 1. Il testo chiaro è lo XOR tra cifrato e stato corrente di qTL *)
  plainBlock = PolynomialMod[cipherBlock + currentTL, 2];
  
  (* 2. Per il round successivo, qTL deve contenere i bit cifrati *)
  newState = state;
  newState[[1 ;; half, 1 ;; half]] = Partition[cipherBlock, half];
  
  {plainBlock, newState}
];

(* Decifratura parametrica da bit cifrati a Stringa *)
CrossSpongeDecString[key_List, iv_List, nWarmRounds_Integer, cipherBits_List] := Module[
  {
    n = Sqrt[Length[key] + Length[iv]],
    rateBits, blocks, state, plainBlocks = {}, res, roundCtr
  },
  
  rateBits = (n / 2)^2;
  blocks = Partition[cipherBits, rateBits];
  state = CrossSpongeWarmUp[key, iv, nWarmRounds];
  roundCtr = nWarmRounds + 1;

  Do[
    (* Decifra il blocco corrente e aggiorna lo stato *)
    res = CrossSpongeDecBlock[state, block];
    AppendTo[plainBlocks, res[[1]]];
    
    (* Permuta lo stato preparandolo al blocco successivo *)
    state = CrossRound[res[[2]], roundCtr];
    roundCtr++;
  , {block, blocks}];

  (* Reinterpreta i bit come testo ASCII *)
  BitsToString[Flatten[plainBlocks]]
];
