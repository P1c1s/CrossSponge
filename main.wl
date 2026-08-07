Get["lib/cross-sponge.wl"]
RandomBits[n_Integer] := RandomInteger[{0,1},n];

keys = {k1, k2, k3, k4, k5, k6, k7, k8};
ivs = {v1, v2, v3, v4, v5, v6, v7, v8};

key = RandomBits[Length[keys]]
iv = RandomBits[Length[ivs]]

word = StringToBits["a"]

Print["Simbolico Round 1"]
CrossSpongeWarmUp[keys, ivs, 1]

Print["Simbolico Round 2"]
Print[CrossSpongeWarmUp[keys, ivs, 2]]

Print["Simbolico Round 3"]
Print[CrossSpongeWarmUp[keys, ivs, 3]]


state = CrossSpongeWarmUp[key, iv, 8];

sponge = Sponge[state, word];


Print["Cifrato"]

CrossSpongeEncString[key, iv, 1, "testo a caso"]
