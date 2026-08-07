RandomBits[n_Integer] := RandomInteger[{0,1},n];

keys = {k1, k2, k3, k4, k5, k6, k7, k8};
ivs = {v1, v2, v3, v4, v5, v6, v7, v8};

key = RandomBits[Length[keys]]
iv = RandomBits[Length[ivs]]

Struct[key_List, iv_List] := Partition[Join[key, iv], Sqrt[Length[Join[key,iv]]]]

SubstitutionLayer[state_List]:= Module[{half, end, qTL, qTR, qBL, qBR},
    end = Length[s];
    half = end / 2;

    (* Quadrante 1: In alto a sinistra (Top-Left) *)
    qTL = state[[1 ;; half, 1 ;; half]];

    (* Quadrante 2: In alto a destra (Top-Right) *)
    qTR = state[[1 ;; half, half + 1 ;; end]];

    (* Quadrante 3: In basso a sinistra (Bottom-Left) *)
    qBL = state[[half + 1 ;; end, 1 ;; half]];

    (* Quadrante 4: In basso a destra (Bottom-Right) *)
    qBR = state[[half + 1 ;; end, half + 1 ;; end]];
    
    Transpose[{Flatten[qTL + qBR], Flatten[qTR + qBL], Flatten[qTL * qBR], Flatten[qTR * qBL]}]
]

ButterFly[key_List, iv_List, nRound_Integer] := Nest[SubstitutionLayer[SubstitutionLayer[#]] &, Struct[key, iv], nRound];

ButterFly[keys, ivs, 1] //MatrixForm

ButterFly[keys, ivs, 2] //MatrixForm

ButterFly[keys, ivs, 3] //MatrixForm



